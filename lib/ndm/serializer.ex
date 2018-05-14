defmodule Ndm.GuardianSerializer do
  @behaviour Guardian.Serializer

def for_token(username) do
	{:ok, "User:#{username}"}
end

def from_token(_), do: {:error, "Unknown resource type"}

end
