#  compositions

A layer of abstraction between Environments and classic modules. The structure runs like this:

1. an Environment (such as "staging") invokes...
1. a particular Composition (such as "digitalmarketplace") using a series of variables which are specific to that original environment. The Composition then...
1. composes itself with a series of Modules, such as...
1. the "single-app" Module invoked several times, for example:
    * single-app Module configured to provide "buyer-frontend" app
    * single-app Module configured to provide "api" app
 