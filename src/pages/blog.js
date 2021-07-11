import * as React from "react"
import { graphql } from "gatsby"
import Layout from "../components/layout.js"

const BlogPage = ({ data }) => {
  return (
    <Layout pageTitle="My Blog Post">
      <p>Cool blog posts here!</p>
      <ul>
        {
          data.allFile.nodes.map(node => <li key={node.name}>{node.name}</li>)
        }
      </ul>
    </Layout>
  )
}

export default BlogPage
export const query = graphql`
  query {
    allFile(filter: {extension: {eq: "mdx"}}) {
      nodes {
        name
      }
    }
  }
`
