import { gql } from "@apollo/client";

export const USER = gql`
  subscription User($id: String) {
    GQLUser(objectId: $id) {
      objectId
      email
      isDeleted
      createdAt
      updatedAt
    }
  }
`;
