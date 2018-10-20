package main

// This is just the skeleton, Echo should be able to handle JSON requests through middleware/controllers.

import (
	"net/http"

	"github.com/GeertJohan/go.rice"
	"github.com/labstack/echo"
)

func main() {
	e := echo.New()
	// the file server for rice. "app" is the folder where the files come from.
	assetHandler := http.FileServer(rice.MustFindBox("app").HTTPBox())
	// serves the index.html from rice
	e.GET("/", echo.WrapHandler(assetHandler))

	// serves other static files
	// the scan results have to be written to ReconPi/dashboard/app
	e.GET("/static/*", echo.WrapHandler(http.StripPrefix("/static/", assetHandler)))

	e.Logger.Fatal(e.Start(":1337"))
}