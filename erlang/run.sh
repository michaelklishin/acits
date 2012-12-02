#!/bin/sh

rebar compile && ERL_LIBS=deps erl -pa ebin -s acits -noshell
