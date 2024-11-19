ollama - ollama interface for Erlang
====================================

This module provides a beamer centric interface to ollama's API.  Currently,
it depends upon my beamer, json, and http modules.


Getting Started
---------------

	ollama:start_link("http://localhost:11434"),
	ollama:response( fun(X) -> io:format("~s~n", [ 
		proplists:get_value(<<"response">>, json:decode(X)) ]) end),
	ollama:generate(<<"write me a poem">>).

Basically, the pattern is start the server, register a function or module:function using
response/1 or response/2 as your handler, and then generate/1 a prompt or embed/1 some input. You can stop/0 at any time.

Installing
----------

To use this module you should first install beamer: https://github.com/cthulhuology/beamer

Then you can do the following:

	beamer deps
	beamer make

Assuming your environment is setup correctly, you can then use ollama: in your projects.


MIT License

Copyright (c) 2023 David J Goehrig

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
