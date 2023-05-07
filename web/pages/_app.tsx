import {
  ApolloClient,
  ApolloProvider,
  HttpLink,
  InMemoryCache,
  split,
} from "@apollo/client";
import {
  ApolloLink,
  FetchResult,
  Observable,
  Operation,
} from "@apollo/client/core";
import { setContext } from "@apollo/client/link/context";
import { getMainDefinition } from "@apollo/client/utilities";
import gqlite from "gqlite-lib";
import { getIdToken } from "gqlite-lib/dist/client/auth";
import { setUrl } from "gqlite-lib/dist/client/utils";
import { css } from "components/editor/css";
import Style from "components/editor/Style";
import { getGQLServerUrl } from "config";
import { AuthProvider } from "contexts/AuthContext";
import { UsersProvider } from "contexts/UsersContext";
import { print } from "graphql";
import { Client, ClientOptions, createClient } from "graphql-ws";
import ModalProvider from "providers/ModalProvider";
import { useEffect, useState } from "react";
import { Toaster } from "react-hot-toast";
import "styles/global.css";

class WebSocketLink extends ApolloLink {
  private client: Client;

  constructor(options: ClientOptions) {
    super();
    this.client = createClient(options);
  }

  public request(operation: Operation): Observable<FetchResult> {
    return new Observable((sink) => {
      return this.client.subscribe<FetchResult>(
        { ...operation, query: print(operation.query) },
        {
          next: sink.next.bind(sink),
          complete: sink.complete.bind(sink),
          error: (err) => {
            if (Array.isArray(err))
              // GraphQLError[]
              return sink.error(
                new Error(err.map(({ message }) => message).join(", "))
              );

            if (err instanceof CloseEvent)
              return sink.error(
                new Error(
                  `Socket closed with event ${err.code} ${err.reason || ""}` // reason will be available on clean closes only
                )
              );

            return sink.error(err);
          },
        }
      );
    });
  }
}

function MyApp({ Component, pageProps }) {
  const [apolloClient, setApolloClient] = useState(null);

  useEffect(() => {
    setUrl(getGQLServerUrl());
    gqlite.utils.useAdminAuthEndpoints(true);

    const wsLink = new WebSocketLink({
      url: `${getGQLServerUrl().replace("http", "ws")}/admin/graphql`,
      connectionParams: async () => {
        const token = await getIdToken();
        if (!token) {
          return {};
        }
        return {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        };
      },
    });

    const httpLink = new HttpLink({
      uri: `${getGQLServerUrl()}/admin/graphql`,
    });

    const splitLink = split(
      ({ query }) => {
        const definition = getMainDefinition(query);
        return (
          definition.kind === "OperationDefinition" &&
          definition.operation === "subscription"
        );
      },
      wsLink,
      httpLink
    );

    const authLink = setContext(async (_, { headers }) => {
      // get the authentication token from local storage if it exists
      const token = await getIdToken();
      // return the headers to the context so httpLink can read them
      return {
        headers: {
          ...headers,
          ...(token && { authorization: `Bearer ${token}` }),
        },
      };
    });

    const client = new ApolloClient({
      link: authLink.concat(splitLink),
      cache: new InMemoryCache({ addTypename: false }),
    });
    setApolloClient(client);
  }, []);

  if (!apolloClient) return null;

  return (
    <>
      <ApolloProvider client={apolloClient}>
        <ModalProvider>
          <AuthProvider>
            <UsersProvider>
              <Toaster position="top-center" />
              <Component {...pageProps} />
            </UsersProvider>
          </AuthProvider>
        </ModalProvider>
      </ApolloProvider>
      <Style css={css} />
    </>
  );
}

export default MyApp;
