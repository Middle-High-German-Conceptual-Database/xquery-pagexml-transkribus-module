# XQuery Module API for Transkribus PageXML

This module provides access to Transkribus PageXML files via Xquery functions. It is designed to be used in context of a Basex xml database, but should work with other xml databases as well.

## Usage

See Documentation https://middle-high-german-conceptual-database.github.io/xquery-pagexml-transkribus-module/

## Transkribus specific features

Transkribus uses the PageXML format to store its data. There are a couple extensions including the use of the attribute @custom to store annotations on text regions, lines and tokens.

This API provides access to these structured strings. Furthermore it provides a simple mechanic to query structures spanning over multiple pages, which can be linked using Transkribus structural metadata.


## Build Documentation

xquerydoc -x /src -o /docs -f markdown