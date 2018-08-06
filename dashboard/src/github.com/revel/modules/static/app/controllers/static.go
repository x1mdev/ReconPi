// Copyright (c) 2012-2016 The Revel Framework Authors, All rights reserved.
// Revel Framework source code and usage is governed by a MIT style
// license that can be found in the LICENSE file.

package controllers

import (
	"os"
	fpath "path/filepath"
	"strings"
	"syscall"

	"fmt"
	"github.com/revel/revel"
	"io/ioutil"
	"net/http"
	"time"
)

// Static file serving controller
type Static struct {
	*revel.Controller
}
type FileInformation struct {
	Icon     string
	Name     string
	Relative string     // Relative path to current request
	Size     int64      // The size of the file
	NiceSize string     // The size of the file
	SizeType string     // The type of size
	Modified *time.Time // The last modified date
}

const (
	B int64 = 1 << (10 * iota) // ignore first value by assigning to blank identifier
	KB
	MB
	GB
	TB
	PB
	EB
)

var byteSizeList = [][]interface{}{
	{"B", B},
	{"KB", KB},
	{"MB", MB},
	{"GB", GB},
	{"TB", TB},
	{"EB", EB},
}

// Serve method handles requests for files. The supplied prefix may be absolute
// or relative. If the prefix is relative it is assumed to be relative to the
// application directory. The filepath may either be just a file or an
// additional filepath to search for the given file. This response may return
// the following responses in the event of an error or invalid request;
//   403(Forbidden): If the prefix filepath combination results in a directory.
//   404(Not found): If the prefix and filepath combination results in a non-existent file.
//   500(Internal Server Error): There are a few edge cases that would likely indicate some configuration error outside of revel.
//
// Note that when defining routes in routes/conf the parameters must not have
// spaces around the comma.
//   Bad:  Static.Serve("public/img", "favicon.png")
//   Good: Static.Serve("public/img","favicon.png")
//
// Examples:
// Serving a directory
//   Route (conf/routes):
//     GET /public/{<.*>filepath} Static.Serve("public")
//   Request:
//     public/js/sessvars.js
//   Calls
//     Static.Serve("public","js/sessvars.js")
//
// Serving a file
//   Route (conf/routes):
//     GET /favicon.ico Static.Serve("public/img","favicon.png")
//   Request:
//     favicon.ico
//   Calls:
//     Static.Serve("public/img", "favicon.png")
func (c Static) Serve(prefix, filepath string) revel.Result {
	// Fix for #503.
	prefix = c.Params.Fixed.Get("prefix")
	if prefix == "" {
		return c.NotFound("")
	}

	return serve(c, prefix, filepath, false)
}

// This function serves out the directory as a browseable folder
func (c Static) ServeDir(prefix, filepath string) revel.Result {
	// Fix for #503.
	prefix = c.Params.Fixed.Get("prefix")
	if prefix == "" {
		return c.NotFound("")
	}

	return serve(c, prefix, filepath, true)
}

// ServeModule method allows modules to serve binary files. The parameters are the same
// as Static.Serve with the additional module name pre-pended to the list of
// arguments.
func (c Static) ServeModule(moduleName, prefix, filepath string) revel.Result {
	// Fix for #503.
	prefix = c.Params.Fixed.Get("prefix")
	if prefix == "" {
		return c.NotFound("")
	}

	var basePath string
	if module, found := revel.ModuleByName(moduleName); !found {
		c.Log.Errorf("static: Module not found %s", moduleName)
		return c.NotFound(moduleName)
	} else {
		basePath = module.Path
	}

	absPath := fpath.Join(basePath, fpath.FromSlash(prefix))

	return serve(c, absPath, filepath, false)
}

// ServeModule method allows modules to serve binary files. The parameters are the same
// as Static.Serve with the additional module name pre-pended to the list of
// arguments.
func (c Static) ServeModuleDir(moduleName, prefix, filepath string) revel.Result {
	// Fix for #503.
	prefix = c.Params.Fixed.Get("prefix")
	if prefix == "" {
		return c.NotFound("")
	}

	var basePath string
	for _, module := range revel.Modules {
		if module.Name == moduleName {
			basePath = module.Path
		}
	}

	absPath := fpath.Join(basePath, fpath.FromSlash(prefix))

	return serve(c, absPath, filepath, true)
}

const DIR_ICON = "folder.png"
const UP_DIR_ICON = "upfolder.png"
const FILE_ICON = "document.png"

// This method allows static serving of application files in a verified manner.
func serve(c Static, prefix, filepath string, allowDir bool) revel.Result {
	var basePath string
	if !fpath.IsAbs(prefix) {
		basePath = revel.BasePath
	}

	basePathPrefix := fpath.Join(basePath, fpath.FromSlash(prefix))
	fname := fpath.Join(basePathPrefix, fpath.FromSlash(filepath))

	// Verify the request file path is within the application's scope of access
	if !strings.HasPrefix(fname, basePathPrefix) {
		c.Log.Warn("Attempted to read file outside of base path", "path", fname, "basePath", basePathPrefix)
		return c.NotFound("")
	}

	// Normalize filepath and verify that the suffix is the same
	if !strings.Contains(fpath.ToSlash(fpath.Clean(fname)), fpath.ToSlash(filepath)) {
		c.Log.Warnf("Attempted to read path structure outside of base path: %s %s", fname, fpath.Clean(filepath))
		return c.NotFound("")
	}

	// Verify file path is accessible
	finfo, err := os.Stat(fname)
	if err != nil {
		if os.IsNotExist(err) || err.(*os.PathError).Err == syscall.ENOTDIR {
			c.Log.Warnf("File not found (%s): %s ", fname, err)
			return c.NotFound("File not found")
		}
		c.Log.Errorf("Error trying to get fileinfo for '%s': %s", fname, err)
		return c.RenderError(err)
	}
	isDir := finfo.Mode().IsDir()
	// Disallow directory listing
	if isDir && !allowDir {
		revel.WARN.Printf("Attempted directory listing of %s", fname)
		return c.Forbidden("Directory listing not allowed")
	}

	if isDir {
		if c.Request.URL.Path[len(c.Request.URL.Path)-1] != '/' {
			c.Response.Out.Header().Set("Location", c.Request.URL.Path+"/")
			c.Response.WriteHeader(http.StatusFound, "")
			// Send redirection
			c.RenderText("Redirecting")
		}

		viewArgs, err := c.processDir(fname, fpath.Join(basePath, prefix))
		if err != nil {
			viewArgs["message"] = fmt.Sprintf("An error occured %s", err.Error())
		}
		c.ViewArgs["details"] = viewArgs
		return c.RenderTemplate("static/folder-view.html")
	}

	// Open request file path
	file, err := os.Open(fname)
	if err != nil {
		if os.IsNotExist(err) {
			c.Log.Warnf("File not found (%s): %s ", fname, err)
			return c.NotFound("File not found")
		}
		c.Log.Errorf("Error opening '%s': %s", fname, err)
		return c.RenderError(err)
	}
	return c.RenderFile(file, revel.Inline)
}

// Process a directory create a list of objects to be rendered representing the data for the directory
func (c *Static) processDir(fullPath, basePath string) (args map[string]interface{}, err error) {
	dirName := fpath.Base(fullPath)
	args = map[string]interface{}{"dirName": dirName}
	// Walk the folder showing up and down links
	dirFiles := []FileInformation{}
	symLinkPath, e := fpath.EvalSymlinks(fullPath)
	if e != nil {
		return args, e
	}

	// Get directory contents
	files, e := ioutil.ReadDir(fullPath)
	if e != nil {
		return nil, e
	}

	if fullPath != basePath {
		fileInfo := FileInformation{Icon: UP_DIR_ICON, Name: c.Message("static\\parent directory"), Relative: "../"}
		dirFiles = append(dirFiles, fileInfo)
	}
	for _, f := range files {
		fileInfo := FileInformation{Name: f.Name()}
		if f.IsDir() {
			fileInfo.Icon = DIR_ICON
			// Check that it is not a symnlink
			realFullPath, _ := fpath.EvalSymlinks(fpath.Join(fullPath, f.Name()))
			if strings.HasPrefix(realFullPath, symLinkPath) {
				// Valid to drill into
				fileInfo.Relative = f.Name() + "/"
			}
		} else {
			fileInfo.Icon = FILE_ICON
			size := "bytes"
			divider := int64(1)
			fileInfo.Size = f.Size()
			for x := 0; fileInfo.Size > byteSizeList[x][1].(int64); x++ {
				size = byteSizeList[x][0].(string)
				divider = byteSizeList[x][1].(int64)
			}
			fileInfo.Size = fileInfo.Size / divider
			fileInfo.SizeType = size
			fileInfo.NiceSize = fmt.Sprintf("%0.1d %s",fileInfo.Size, size)
			fileInfo.Relative = fileInfo.Name
		}
		modified := f.ModTime()
		fileInfo.Modified = &modified
		dirFiles = append(dirFiles, fileInfo)
	}
	args["content"] = dirFiles
	args["count"] = len(dirFiles)
	args["dateformat"] = revel.Config.StringDefault("static.dateformat", "2006-01-02 15:04:05 MST")
	return
}
