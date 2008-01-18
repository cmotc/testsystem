all: runtests

runtests:
	@./runtests

status:
	@./status

clean:
	rm -rf tmp

stop-testsystem:
	@crontab -r || printf "Testsystem was already disabled.\n"
	@printf "No new tests will be executed.\n"
	@printf "Run 'make start-testsystem' to (re-)start fetching new tests\n"

start-testsystem:
	@crontab crontab-testsystem
	@printf "New tests will be executed every 15 minutes if available.\n"
	@printf "Run 'make stop-testsystem' to stop fetching new tests.\n"
	
.PHONY: all runtests status clean stop-testsystem start-testsystem
