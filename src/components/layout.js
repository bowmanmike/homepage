import * as React from "react"
import { Link, useStaticQuery, graphql } from "gatsby"

const Layout = ({pageTitle, children}) => {
  const data = useStaticQuery(graphql`
    query {
      site {
        siteMetadata {
          title
        }
      }
    }
    `)
  return (
    <main className="m-auto max-w-screen-sm font-sans">
      <title>{pageTitle} | {data.site.siteMetadata.title}</title>
      <p className="text-5xl text-gray-600 font-bold">{data.site.siteMetadata.title}</p>
      <nav>
        <ul className="flex list-none pl-0">
          <li className="pr-8"><Link to="/" className="text-black">Home</Link></li>
          <li className="pr-8"><Link to="/about" className="text-black">About</Link></li>
          <li className="pr-8"><Link to="/blog" className="text-black">Blog</Link></li>
        </ul>
      </nav>
      <h1 className="text-purple-800">{pageTitle}</h1>
      {children}
    </main>
  )
}

export default Layout
