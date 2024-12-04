phony: cover dev install test

cover:
	cd valentine && mix test --cover

dev:
	cd valentine && mix phx.server

install:
	cd valentine && mix deps.get

fmt:
	cd valentine && mix format

test:
	cd valentine && mix test