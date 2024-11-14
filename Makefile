phony: ai cover dev install test

ai:
	find $(dir) -type f -exec cat {} + > ai-out.txt

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