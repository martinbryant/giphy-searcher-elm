# Part 4 of my Web Development portfolio

Inspired by [5 Projects To Complete When Starting to Learn Front-End Web Development](https://medium.com/@GarrettLevine/5-projects-to-complete-when-starting-to-learn-front-end-web-development-48e8a1ce3178 "medium.com")

An excellent beginning application to build is a basic re-creation of the the giphy website, using the giphy api itself. I recommend their API for beginners because there is no need to request any kind of API key, and you won’t have to worry about much configuration when trying to request data.

Using their API you are able to build a small web app which does the following;

* Displays trending gifs on app load shown in a column/grid
* Has an input which allows you to search for specific gifs
* At the bottom of the results, there is a ‘load more’ button, which gets more gifs using that search term.

[Giphy Searcher in Elm](http://martinbryant.io/giphy-searcher-elm/ "Giphy Searcher") 

## Challenges

* Responsive Design using CSS Grid
* Calling a different API endpoint for trending and search
* Adding validation to prevent a blank search
* Hooking up the Load More button to only display when needed

## Takeaways

* Learnt about Json decoders to get the correct API shape
* Used withOptions on a form to preventDefault and stopPropagation when submitting

## Acknowledgments
[Garrett Levine](https://medium.com/@GarrettLevine "Garrett Levine on Medium") - Thank you for the great article