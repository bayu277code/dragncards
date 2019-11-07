defmodule SpadesGame.GameUI do
  @moduledoc """
  One level on top of Game.
  """

  alias SpadesGame.{Card, Game, GameUI, GameOptions}

  @derive Jason.Encoder
  defstruct [:game, :game_name, :options, :created_at, :status, :seats, :when_seats_full]

  use Accessible

  @type t :: %GameUI{
          game: Game.t(),
          game_name: String.t(),
          options: GameOptions.t(),
          created_at: DateTime.t(),
          status: :staging | :playing | :done,
          seats: %{
            west: nil | integer,
            north: nil | integer,
            east: nil | integer,
            south: nil | integer
          },
          when_seats_full: nil | DateTime.t()
        }

  @spec new(String.t(), GameOptions.t()) :: GameUI.t()
  def new(game_name, %GameOptions{} = options) do
    game = Game.new(game_name, options)

    %GameUI{
      game: game,
      game_name: game_name,
      options: options,
      created_at: DateTime.utc_now(),
      status: :staging,
      seats: %{
        west: nil,
        north: nil,
        east: nil,
        south: nil
      }
    }
  end

  @doc """
  censor_hands/1: Return a version of GameUI with all hands hidden.
  """
  @spec censor_hands(GameUI.t()) :: GameUI.t()
  def censor_hands(gameui) do
    gameui
    |> put_in([:game, :east, :hand], [])
    |> put_in([:game, :north, :hand], [])
    |> put_in([:game, :south, :hand], [])
    |> put_in([:game, :west, :hand], [])
  end

  @doc """
  bid/3: User bid `bid_amount` of tricks.
  """
  @spec bid(GameUI.t(), number, number) :: GameUI.t()
  def bid(game_ui, user_id, bid_amount) do
    seat = user_id_to_seat(game_ui, user_id)

    if seat == nil do
      game_ui
    else
      case Game.bid(game_ui.game, seat, bid_amount) do
        {:ok, new_game} ->
          %{game_ui | game: new_game}
          |> checks

        {:error, _msg} ->
          game_ui
      end
    end
  end

  @doc """
  play/3: A player puts a card on the table. (Moves from hand to trick.)
  """
  @spec bid(GameUI.t(), number, Card.t()) :: GameUI.t()
  def play(game_ui, user_id, card) do
    seat = user_id_to_seat(game_ui, user_id)

    if seat == nil do
      game_ui
    else
      case Game.play(game_ui.game, seat, card) do
        {:ok, new_game} ->
          %{game_ui | game: new_game}
          |> checks

        {:error, _msg} ->
          game_ui
      end
    end
  end

  @doc """
  user_id_to_seat/2: Which seat is this user sitting in?
  """
  @spec user_id_to_seat(GameUI.t(), number) :: nil | :west | :east | :north | :south
  def user_id_to_seat(game_ui, user_id) do
    game_ui.seats
    |> Map.new(fn {k, v} -> {v, k} end)
    |> Map.delete(nil)
    |> Map.get(user_id)
  end

  @doc """
  discard/1: Someone moved a card from the draw pile to the discard pile.
  Function for testing simple UI state that should eventually be removed.
  """
  @spec discard(GameUI.t()) :: GameUI.t()
  def discard(gameui) do
    game = Game.discard(gameui.game)
    %{gameui | game: game}
  end

  @doc """
  checks/1: Applies checks to GameUI and return an updated copy.

  Generally, all "checks" we append to all outputs.
  These are all derived state updates.  If something
  needs to fire off a timer or something, it will be here.
  It's always safe to call this function.
  """
  @spec checks(GameUI.t()) :: GameUI.t()
  def checks(gameui) do
    gameui
    |> check_full_seats
    |> check_status_advance
    |> check_game
  end

  @doc """
  sit/3: User is attempting to sit in a seat.
  Let them do it if no one is in the seat, and they are not
  in any other seats.  Otherwise return the game unchanged.
  --> sit(gameui, userid, which_seat)
  """
  @spec sit(GameUI.t(), integer, String.t()) :: GameUI.t()
  def sit(gameui, userid, "north"), do: do_sit(gameui, userid, :north)
  def sit(gameui, userid, "south"), do: do_sit(gameui, userid, :south)
  def sit(gameui, userid, "east"), do: do_sit(gameui, userid, :east)
  def sit(gameui, userid, "west"), do: do_sit(gameui, userid, :west)
  def sit(gameui, _userid, _), do: gameui |> checks

  @spec do_sit(GameUI.t(), integer, :north | :south | :east | :west) :: GameUI.t()
  defp do_sit(gameui, userid, which) do
    if sit_allowed?(gameui, userid, which) do
      seats = gameui.seats |> Map.put(which, userid)

      %GameUI{gameui | seats: seats}
      |> checks
    else
      gameui
      |> checks
    end
  end

  # Is this user allowed to sit in this seat?
  @spec sit_allowed?(GameUI.t(), integer, :north | :south | :east | :west) :: boolean
  defp sit_allowed?(gameui, userid, which) do
    !already_sitting?(gameui, userid) && seat_empty?(gameui, which)
  end

  # Is this user sitting in a seat?
  @spec seat_empty?(GameUI.t(), integer) :: boolean
  defp already_sitting?(gameui, userid) do
    gameui.seats |> Map.values() |> Enum.member?(userid)
  end

  # Is this seat empty?
  @spec seat_empty?(GameUI.t(), :north | :south | :east | :west) :: boolean
  defp seat_empty?(gameui, which), do: gameui.seats[which] == nil

  @doc """
  leave/2: Userid just left the table.  If they were seated, mark
  their seat as vacant.
  """
  @spec leave(GameUI.t(), integer) :: GameUI.t()
  def leave(gameui, userid) do
    seats = for {k, v} <- gameui.seats, into: %{}, do: {k, if(v == userid, do: nil, else: v)}

    %{gameui | seats: seats}
    |> checks
  end

  @doc """
  check_full_seats/1
  When the last person sits down and all of the seats are full, put a timestamp
  on ".when_seats_full".
  If there is a timestamp set, and someone just stood up, clear the timestamp.
  """
  @spec check_full_seats(GameUI.t()) :: GameUI.t()
  def check_full_seats(%GameUI{} = gameui) do
    cond do
      everyone_sitting?(gameui) and gameui.when_seats_full == nil ->
        %{gameui | when_seats_full: DateTime.utc_now()}

      not everyone_sitting?(gameui) and gameui.when_seats_full != nil ->
        %{gameui | when_seats_full: nil}

      true ->
        gameui
    end
  end

  @doc """
  check_game/1: 
  Run the series of checks on the Game object.
  Similar to GameUI's checks(), but running on the embedded
  game_ui.game object/level instead.
  """
  @spec check_game(GameUI.t()) :: GameUI.t()
  def check_game(%GameUI{} = game_ui) do
    {:ok, game} = Game.checks(game_ui.game)
    %GameUI{game_ui | game: game}
  end

  @doc """
  check_status_advance/1: Move a game's status when appropriate.
  :staging -> :playing -> :done
  """
  @spec check_status_advance(GameUI.t()) :: GameUI.t()
  def check_status_advance(%GameUI{status: :staging} = gameui) do
    if everyone_sitting?(gameui) and seat_full_countdown_finished?(gameui) do
      %{gameui | status: :playing}
    else
      gameui
    end
  end

  ## Don't have winners yet
  # def check_status_advance(%GameUI{status: :playing, game: %Game{winner: winner}} = gameui)
  #     when not is_nil(winner) do
  #   %{gameui | status: :done}
  # end

  def check_status_advance(gameui) do
    gameui
  end

  @doc """
  everyone_sitting?/1:
  Does each seat have a person sitting in it?
  """
  @spec everyone_sitting?(GameUI.t()) :: boolean
  def everyone_sitting?(gameui) do
    [:north, :west, :south, :east]
    |> Enum.reduce(true, fn seat, acc ->
      acc and gameui.seats[seat] != nil
    end)
  end

  @doc """
  trick_full?/1:
  Does the game's current trick have one card for each player?
  """
  @spec trick_full?(GameUI.t()) :: boolean
  def trick_full?(game_ui) do
    Game.trick_full?(game_ui.game)
  end

  @doc """
  seat_full_countdown_finished?/1
  Is the "when_seats_full" timestamp at least 10 seconds old?
  """
  @spec seat_full_countdown_finished?(GameUI.t()) :: boolean
  def seat_full_countdown_finished?(%GameUI{when_seats_full: nil}) do
    false
  end

  def seat_full_countdown_finished?(%GameUI{when_seats_full: when_seats_full}) do
    time_elapsed = DateTime.diff(DateTime.utc_now(), when_seats_full, :millisecond)
    # 10 seconds
    time_elapsed >= 10 * 1000
  end

  @doc """
  rewind_countdown_devtest/1:
  If a "when_trick_full" timestamp is set, rewind it to be
  10 minutes ago.  Also run check_for_trick_winner.  Used in
  dev and testing for instant trick advance only.
  """
  @spec rewind_countdown_devtest(GameUI.t()) :: GameUI.t()
  def rewind_countdown_devtest(%GameUI{when_seats_full: when_seats_full} = game_ui) do
    if when_seats_full == nil do
      game_ui
      |> checks
    else
      ten_mins_in_seconds = 60 * 10
      nt = DateTime.add(when_seats_full, -1 * ten_mins_in_seconds, :second)

      %GameUI{game_ui | when_seats_full: nt}
      |> checks
    end
  end

  @spec rewind_trickfull_devtest(GameUI.t()) :: GameUI.t()
  def rewind_trickfull_devtest(game_ui) do
    %GameUI{game_ui | game: Game.rewind_trickfull_devtest(game_ui.game)}
    |> checks
  end
end
