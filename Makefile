.PHONY: up
up:
	@docker-compose up -d
# Wait
	@while true; do echo Waiting... && curl -s -o /dev/null http://localhost:8088 && break || sleep 3; done
# Default
	@docker exec redmine env RAILS_ENV=production REDMINE_LANG=ja bundle exec rake redmine:load_default_data
# Memcached
	@docker exec redmine sh -c "echo 'config.cache_store = :mem_cache_store, \"memcached\"' > config/additional_environment.rb"
	@docker exec redmine sh -c "echo \"gem 'dalli'\" > Gemfile.local"
	@docker exec redmine bundle install
	@docker exec redmine passenger-config restart-app /usr/src/redmine
# Configuration
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e 'INSERT INTO `settings` (`name`, `value`) VALUES ("search_results_per_page","30");'
	@docker exec redmine_mysql mysql -B -uredmine -predmine redmine -e 'INSERT INTO `settings` (`name`, `value`) VALUES ("text_formatting","markdown");'

.PHONY: down
down:
	@docker-compose down
