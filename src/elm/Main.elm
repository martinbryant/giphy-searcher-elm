module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, disabled)
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
    ( Model "" [] 5 0, Cmd.none )


type alias Model =
    { searchTerm : String
    , giphyUrlList : List String
    , giphsToLoad : Int
    , giphsOffset : Int
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
giphySearchUrl { searchTerm, giphsToLoad, giphsOffset } =
    "http://api.giphy.com/v1/gifs/search?q="
        ++ searchTerm
        ++ "&limit="
        ++ (toString giphsToLoad)
        ++ "&offset="
        ++ (toString giphsOffset)
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
                    { model | giphsOffset = 0 }
            in
                ( newModel, getGiphSearch newModel )

        AddMoreGiphs ->
            let
                newModel =
                    { model | giphsOffset = model.giphsOffset + 5 }
            in
                ( newModel, getGiphSearch newModel )

        RecieveGiphList (Ok urls) ->
            ( { model | giphyUrlList = isSearchNew model urls }, Cmd.none )

        RecieveGiphList (Err error) ->
            ( { model | giphyUrlList = [] }, Cmd.none )


isSearchNew : Model -> List String -> List String
isSearchNew model urls =
    case model.giphsOffset of
        0 ->
            urls

        _ ->
            List.append model.giphyUrlList urls


isSearchTermValid : String -> Maybe String
isSearchTermValid searchTerm =
    case searchTerm of
        "" ->
            Just "Cannot be blank"

        _ ->
            Nothing



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
                , disabled <| isSearchFormBlank model
                , onClick SubmitSearch
                ]
                [ text "Search Giphy" ]
            ]
        , div [ class "result-display" ]
            [ giphsView model ]
        , div
            [ id "add-more"
            , class "add-more-button"
            ]
            [ button
                [ onClick AddMoreGiphs
                , disabled <| List.isEmpty model.giphyUrlList
                ]
                [ text "Load more" ]
            ]
        ]


isSearchFormBlank : Model -> Bool
isSearchFormBlank { searchTerm } =
    searchTerm == ""



-- giphView : Model -> Html msg
-- giphView model =
--     case model.giphyUrlList of
--         NotAsked ->
--             noGiphView
--         Loading ->
--             loadingView
--         Success urlList ->
--             giphsView urlList
--         Failure error ->
--             errorView <| toString <| error


noGiphView : Html msg
noGiphView =
    div [] []


loadingView : Html msg
loadingView =
    div [] [ text "Spinner" ]


giphsView : Model -> Html msg
giphsView { giphyUrlList } =
    div [ class "result-grid" ]
        (List.map renderPictureBox giphyUrlList)


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
--Auto loading on scroll
