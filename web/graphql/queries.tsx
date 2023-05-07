import { gql } from "@apollo/client";

export const USERS = gql`
  query GetUsers {
    GQLUsers {
      objectId
      email
      isDeleted
      createdAt
      updatedAt
    }
  }
`;
