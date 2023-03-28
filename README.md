# Pairing

This project is an example project built for as a coding exercise for Tandem.

The purpose of the project is described here
![assumptions](./priv/static/images/assumptions.png)

The workflow diagram created is here (PDF)
![workflow](./priv/static/images/initial_wireframes.png)

The database architecture is here (PDF)
![database](./priv/static/images/database.png)

To build this application to work, you must have the following installed: 
1. Elixir (It will auto install the other packages and languages needed, i.e. Erlang, Mix, etc)
2. PostgreSQL (there are a lot of tutorials for this, we won't go into that now)

The easiest way to do this is via Homebrew:
`brew install elixir`

You may need to set the PATH environment variable. More information may be found [here:](https://elixir-lang.org/install.html)

Once installed, verify you're Elixir version with `elixir -v`. You should see something like:
```elixir
Erlang/OTP 25 [erts-13.0.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Elixir 1.14.3 (compiled with Erlang/OTP 23)
```

After the main tool is installed, you can clone this repo to any directory. CD into that directory, then you should be able to run this to have the dependencies to run the application:
`mix setup` 

Then run the app with `mix phx.server`


Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.