import Api exposing (..)
import Http
import Html exposing (Html)

main =
  Html.program { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }

init : ((), Cmd Msg)
init =
  ((), get "http://localhost:8080" |> Http.send LoadedFoo)


-- UPDATE

type Msg = LoadedFoo (Result Http.Error Foo)

update : Msg -> () -> ((), Cmd Msg)
update msg model =
  case msg of
    LoadedFoo (Ok data) ->
      Debug.crash (toString data)
    LoadedFoo (Err error) ->
      Debug.crash (toString error)


-- VIEW

view : () -> Html Msg
view () =
  Html.div []
    [ Html.text ":O" ]
