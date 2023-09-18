import Config

http_port =
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "8080"),
    else: System.get_env("TODO_TEST_HTTP_PORT", "8888")
config :todo, http_port: String.to_integer(http_port)

db_folder =
  if config_env() != :test,
    do: System.get_env("TODO_DB_FOLDER", "./persist"),
    else: System.get_env("TODO_DB_FOLDER", "./persist") <> "_test"

config :todo, db_folder: db_folder
