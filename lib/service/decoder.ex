defmodule DMCD.Service.Decoder do
  @moduledoc """
  Decoder service that maps morse codes to alphanumeric characters
  """

  @space_code "......."
  @codes_map %{
    ".-" => "A",
    "-..." => "B",
    "-.-." => "C",
    "-.." => "D",
    "." => "E",
    "..-." => "F",
    "--." => "G",
    "...." => "H",
    ".." => "I",
    ".---" => "J",
    "-.-" => "K",
    ".-.." => "L",
    "--" => "M",
    "-." => "N",
    "---" => "O",
    ".--." => "P",
    "--.-" => "Q",
    ".-." => "R",
    "..." => "S",
    "-" => "T",
    "..-" => "U",
    "...-" => "V",
    ".--" => "W",
    "-..-" => "X",
    "-.--" => "Y",
    "--.." => "Z",
    "-----" => "0",
    ".----" => "1",
    "..---" => "2",
    "...--" => "3",
    "....-" => "4",
    "....." => "5",
    "-...." => "6",
    "--..." => "7",
    "---.." => "8",
    "----." => "9",
    ".-.-.-" => ".",
    "--..--" => ",",
    "..--.." => "?",
    ".----." => "'",
    "-.-.--" => "!",
    "-..-." => "/",
    "-.--." => "(",
    "-.--.-" => ")",
    ".-..." => "&",
    "---..." => ":",
    "-.-.-." => ";",
    "-...-" => "=",
    ".-.-." => "+",
    "-....-" => "-",
    "..--.-" => "_",
    "...-..-" => "$",
    ".--.-." => "@",
    @space_code => " "
  }

  @spec run(binary) :: binary
  def run(coded_msg) do
    coded_msg
    |> String.split(" ")
    |> Enum.map(&Map.get(@codes_map, &1))
    |> Enum.join("")
  end

  @spec supported?(binary) :: boolean
  def supported?(code), do: is_binary(Map.get(@codes_map, code))

  @spec space_code :: binary
  def space_code, do: @space_code
end
