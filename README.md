# NDM

NDM provides a neopets automation tools in a web/native app.

- **Account Management**. Add/Remove neopets user accounts for automation.
- **Daily Automator**. Automatically peform daily tasks such as spinning wheels and collecting interest.
- **Stock Broker**. Stocks management that will automatically monitor stocks at 15 NP and sell when they've hit your threshold.
- **Shop Management**. Automatically price items in your user shop.
- **Main Shop Autobuyer**. Centralize your discussions around translations.
- **Other**. More ideas will be added soon.

## Contents

| Section                                             | Description                                                          |
| --------------------------------------------------- | -------------------------------------------------------------------- |
| [Requirements](#-requirements)                   | Dependencies required to run NDM                                     |
| [Getting Started](#-getting-started)             | Quickly setup a working app                                          |
| [Account Management](#-account-management)       | How to execute mix task with the Twelve-Factor pattern               |
| [Daily Automator](#-daily-automator)             | Dailies automator results and configuration                          |
| [Shop Management](#-shop-management)             | Shop management configuration                                        |
| [Main Shop Autobuyer](#-main-shop-autobuyer)     | How configure and run the main shop autobuyer                        |
| [Other](#-other)                                 | Information on other features to be added                            |
| [Disclaimers](#-disclaimers)                     | Some discailmers about the safety of this project                    |

## Requirements

- `erlang ~> 21.2`
- `elixir ~> 1.9`
- `postgres >= 9.4`
- `node.js >= 8.5.0`

## Getting Started

1. If you don’t already have it, install `npm` with `brew install npm`
2. If you don’t already have it, install `elixir` with `brew install elixir`
3. If you don’t already have it, install `postgres` with `brew install postgres` or the Docker setup as described below.
4. Install dependencies with `make dependencies`
5. Create and migrate your database with `mix ecto.setup`
6. Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Account Management

## Daily Automator

## Shop Management

## Main Shop Autobuyer

## Other

## Disclaimers
This project has been created for educational purposes and to further my knowledge web application development.