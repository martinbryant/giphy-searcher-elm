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
    ( Model "" NotAsked 10 0, Cmd.none )


type alias Model =
    { searchTerm : String
    , giphyUrlList : WebData (List String)
    , giphsToLoad : Int
    , giphOffset : Int
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
    Json.Decode.at [ "images", "fixed_height_downsampled", "url" ] Json.Decode.string


giphyDataDecoder : Decoder (List String)
giphyDataDecoder =
    Json.Decode.at [ "data" ] (list giphyUrlDecoder)


getGiphSearch : Model -> Cmd Msg
getGiphSearch model =
    Http.send RecieveGiphList <|
        Http.get
            (giphySearchUrl model)
            giphyDataDecoder


giphySearchUrl : Model -> String
giphySearchUrl { searchTerm, giphsToLoad, giphOffset } =
    "http://api.giphy.com/v1/gifs/search?q="
        ++ searchTerm
        ++ "&limit="
        ++ (toString giphsToLoad)
        ++ "&offset="
        ++ (toString giphOffset)
        ++ "&api_key=FnWOsAt1MrjCleoqgtcZS57GN8HjKn0j"



-- UPDATE


type Msg
    = UpdateSearchField String
    | SubmitSearch
    | AddMoreGiphs
    | RecieveGiphList (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchField searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        SubmitSearch ->
            let
                newModel =
                    { model
                        | giphyUrlList = Loading
                        , giphsToLoad = 10
                    }
            in
                ( newModel
                , getGiphSearch newModel
                )

        AddMoreGiphs ->
            let
                newModel =
                    { model
                        | giphyUrlList = Loading
                        , giphsToLoad = model.giphsToLoad + 10
                    }
            in
                ( newModel
                , getGiphSearch newModel
                )

        RecieveGiphList (Ok urls) ->
            ( { model
                | giphyUrlList = Success urls
              }
            , Cmd.none
            )

        RecieveGiphList (Err error) ->
            ( { model | giphyUrlList = Failure error }, Cmd.none )



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
                [ text "Search Giphy" ]
            ]
        , div [ class "result-display" ]
            [ giphView model ]
        , div [ class "add-more-button" ]
            [ button [ onClick AddMoreGiphs ] [ text "Load more" ] ]
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
    div [ class "result-grid" ]
        (List.map
            renderPictureBox
            urlList
        )


errorView : String -> Html msg
errorView error =
    text <| toString <| error


renderPictureBox : String -> Html msg
renderPictureBox url =
    img [ class "giph", Html.Attributes.src url ] []



--TODO LIST
--Add validation to the search bar to prevent blank input
--Hook up load more button
--Add styling including responsive design and spinner
--Conditional load more button
--Add change layout button
--Add number of giphs to load button
