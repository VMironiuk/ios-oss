import GraphAPI

extension GraphAPI.PostCommentInput {
  static func from(_ input: PostCommentInput) -> GraphAPI.PostCommentInput {
    return GraphAPI.PostCommentInput(
      commentableId: input.commentableId,
      body: input.body,
      parentId: GraphQLNullable.someOrNil(input.parentId)
    )
  }
}
