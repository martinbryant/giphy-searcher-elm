module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, at, list)


-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


init : ( Model, Cmd Msg )
init =
    ( Model "" NotAsked, Cmd.none )


type alias Model =
    { searchTerm : String
    , giphyUrlList : WebData (List String)
    }


type RequestData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a


type alias WebData a =
    RequestData Http.Error a



--DATA


giphyUrlDecoder : Decoder String
giphyUrlDecoder =
    Json.Decode.at [ "images", "fixed_width", "url" ] Json.Decode.string


giphyDataDecoder : Decoder (List String)
giphyDataDecoder =
    Json.Decode.at [ "data" ] (list giphyUrlDecoder)


getGiphSearch : Model -> Cmd Msg
getGiphSearch { searchTerm } =
    Http.send RecieveGiphList <|
        Http.get
            (giphySearchUrl searchTerm)
            giphyDataDecoder


giphySearchUrl : String -> String
giphySearchUrl searchTerm =
    "http://api.giphy.com/v1/gifs/search?q=" ++ searchTerm ++ "&limit=2&api_key=FnWOsAt1MrjCleoqgtcZS57GN8HjKn0j"



-- http://api.giphy.com/v1/gifs/search?q=funny+cat&limit=1&api_key=FnWOsAt1MrjCleoqgtcZS57GN8HjKn0j
-- UPDATE


type Msg
    = UpdateSearchField String
    | SubmitSearch
    | RecieveGiphList (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchField searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        SubmitSearch ->
            ( { model | giphyUrlList = Loading }, getGiphSearch model )

        RecieveGiphList (Ok url) ->
            ( { model | giphyUrlList = Success (url) }, Cmd.none )

        RecieveGiphList (Err error) ->
            ( { model | giphyUrlList = Failure (error) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "title" ]
            [ h1 [] [ text "Giphy Searcher" ]
            ]
        , div [ class "search-form" ]
            [ input
                [ class "search-input"
                , onInput UpdateSearchField
                ]
                []
            , button
                [ class "search-button"
                , onClick SubmitSearch
                ]
                []
            ]
        , div [ class "result-display" ]
            [ giphView model ]
        ]


giphView : Model -> Html msg
giphView model =
    case model.giphyUrlList of
        NotAsked ->
            noGiphView

        Loading ->
            loadingView

        Success urlList ->
            giphsView urlList

        Failure error ->
            errorView <| toString <| error


noGiphView : Html msg
noGiphView =
    div [] []


loadingView : Html msg
loadingView =
    div [] [ text "Spinner" ]


giphsView : List String -> Html msg
giphsView urlList =
    div []
        (List.map
            renderPictureBox
            urlList
        )


errorView : String -> Html msg
errorView error =
    text <| toString <| error


renderPictureBox : String -> Html msg
renderPictureBox url =
    img [ Html.Attributes.src url ] []
