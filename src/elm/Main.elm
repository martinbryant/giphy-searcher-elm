module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, disabled, type_, name)
import Html.Events exposing (onClick, onSubmit, onWithOptions, Options)
import Http
import Json.Decode as Json exposing (Decoder)


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
    ( Model "" Nothing 5 [] Loading, getTrendingGif )


type alias Model =
    { searchTerm : String
    , searchError : Maybe String
    , gifsRequired : Int
    , loadedGifList : List String
    , newGifs : WebData (List String)
    }


type RequestData e a
    = NotAsked
    | Loading
    | Failure e
    | Success a


type alias WebData a =
    RequestData Http.Error a



--DATA


gifUrlDecoder : Decoder String
gifUrlDecoder =
    Json.at [ "images", "fixed_height_downsampled", "url" ] Json.string


gifDataDecoder : Decoder (List String)
gifDataDecoder =
    Json.at [ "data" ] (Json.list gifUrlDecoder)


getGifSearch : Model -> Cmd Msg
getGifSearch model =
    Http.send RecieveGifList <|
        Http.get
            (gifSearchUrl model)
            gifDataDecoder


gifSearchUrl : Model -> String
gifSearchUrl model =
    "http://api.giphy.com/v1/gifs/search?q="
        ++ model.searchTerm
        ++ "&limit="
        ++ (toString model.gifsRequired)
        ++ "&offset="
        ++ (toString <| calcOffset model.loadedGifList)
        ++ "&api_key=FnWOsAt1MrjCleoqgtcZS57GN8HjKn0j"


calcOffset : List String -> Int
calcOffset gifList =
    List.length gifList


getTrendingGif : Cmd Msg
getTrendingGif =
    Http.send RecieveGifList <|
        Http.get
            gifTrendingUrl
            gifDataDecoder


gifTrendingUrl : String
gifTrendingUrl =
    "http://api.giphy.com/v1/gifs/trending?"
        ++ "limit=10"
        ++ "&api_key=FnWOsAt1MrjCleoqgtcZS57GN8HjKn0j"



-- UPDATE


type Msg
    = SubmitSearch String
    | LoadMoreGifs
    | RecieveGifList (Result Http.Error (List String))



-- | AddMoreGiphs


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitSearch searchTerm ->
            if String.isEmpty searchTerm then
                ( { model | searchError = Just "Search cannot be blank" }, Cmd.none )
            else
                let
                    newModel =
                        { model
                            | searchTerm = searchTerm
                            , searchError = Nothing
                            , loadedGifList = []
                            , newGifs = Loading
                        }
                in
                    ( newModel, getGifSearch newModel )

        LoadMoreGifs ->
            ( { model | newGifs = Loading }, getGifSearch model )

        RecieveGifList (Ok urls) ->
            ( { model
                | newGifs =
                    (if String.isEmpty model.searchTerm then
                        NotAsked
                     else
                        Success urls
                    )
                , loadedGifList = List.append model.loadedGifList urls
              }
            , Cmd.none
            )

        RecieveGifList (Err error) ->
            ( { model | newGifs = Failure error }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "title" ]
            [ h1 [] [ text "Giphy Searcher" ]
            ]
        , div [ class "search" ]
            [ searchFormView
            , searchBoxValidationView model.searchError
            ]
        , div [ class "result-display" ]
            [ gifView model.loadedGifList ]
        , div [ class "loading-section" ] [ calcLoadingView model.newGifs ]
        ]


searchFormView : Html Msg
searchFormView =
    form
        [ class "search-form"
        , onWithOptions "submit"
            (Options True True)
            decodeForm
        ]
        [ input
            [ class "search-input"
            , name "search-term"
            , type_ "text"
            ]
            []
        , input
            [ class "search-button"
            , type_ "submit"
            ]
            [ text "Search Giphy" ]
        ]


decodeField : String -> Decoder String
decodeField name =
    Json.at
        [ "currentTarget"
        , name
        , "value"
        ]
        Json.string


decodeForm : Decoder Msg
decodeForm =
    Json.map
        SubmitSearch
        (decodeField "search-term")


searchBoxValidationView : Maybe String -> Html msg
searchBoxValidationView searchError =
    case searchError of
        Just errMsg ->
            div [ class "search-error" ] [ text errMsg ]

        Nothing ->
            text ""


gifView : List String -> Html msg
gifView loadedGifList =
    div [ class "result-grid" ]
        (List.map
            renderPictureBox
            loadedGifList
        )


renderPictureBox : String -> Html msg
renderPictureBox url =
    img [ class "gif", Html.Attributes.src url ] []


calcLoadingView : WebData a -> Html Msg
calcLoadingView newGifs =
    case newGifs of
        NotAsked ->
            div [] []

        Loading ->
            loadingView

        Success a ->
            loadMoreButtonView

        Failure e ->
            div [ class "error-message" ]
                [ errorView e ]


loadingView : Html msg
loadingView =
    i [ class "spinner fas fa-spinner fa-spin fa-4x" ] []


loadMoreButtonView : Html Msg
loadMoreButtonView =
    button
        [ class "load-more-button"
        , onClick LoadMoreGifs
        ]
        [ text "Load more" ]


errorView : Http.Error -> Html msg
errorView error =
    case error of
        Http.Timeout ->
            text "Timeout Error"

        Http.NetworkError ->
            text "Network Error"

        Http.BadPayload e a ->
            text <| "Payload Error"

        Http.BadUrl a ->
            text "BadUrl Error"

        Http.BadStatus a ->
            text "BadStatus Error"



--TODO LIST
--Add validation to the search bar to prevent blank input Y
--Hook up load more button Y
--Cover all network error messages
--trending gifs on page load
--Add styling including responsive design and spinner
--Conditional load more button Y
--Add change layout button
--Add number of giphs to load button
--Auto loading on scroll
