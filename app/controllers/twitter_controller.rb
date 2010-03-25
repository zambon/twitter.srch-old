class TwitterController < ApplicationController
  
  require 'open-uri'
  require 'json'
  
  # Index action.
  def index
    @query = Query.new
    @queries = Query.find(:all, :order => 'updated_at DESC', :limit => 7)
  end
  
  # Creates the Twitter Search API query and call the service.
  def search_twitter(query)
    
    url = "http://search.twitter.com/search.json"
    
    if (not query.q.nil? and not query.q.empty?) and (not query.from_user.nil? and not query.from_user.empty?)
      url << "?q=" + CGI.escape(query.q) + "+from%3A" + CGI.escape(query.from_user)
    elsif query.q.nil? or query.q.empty?
      url << "?q=from%3A" + CGI.escape(query.from_user)
    elsif query.from_user.nil? or query.from_user.empty?
      url << "?q=" + CGI.escape(query.q)
    end
    
    url << "&lang=" + CGI.escape(query.lang) if not query.lang.nil? and not query.lang.empty?
    url << "&rpp=" + query.rpp.to_s
    url << "&since=" + "%04d-%02d-%02d" % [query.since.year, query.since.month, query.since.day] if not query.since.nil?
    
    JSON.parse(open(url).read)['results']
  end
  
  ## Validates the query parameters, save or update the correspondent Query
  # object, call the search_twitter() method and updates the page with the
  # results.
  def search
    if request.xhr?
      ## Instantiates a new Query object
      query = Query.new(params[:query])
      
      ## Workaround
      # When creating a new Query object by passing the ajax parameters, the
      # empty parameters should be considered nil
      query.from_user = nil if query.from_user == ''
      query.lang = nil if query.lang == ''
      query.q = nil if query.q == ''
      
      #puts query.inspect
      
      ## Query object validation
      if not query.valid?
        respond_to do |format|
          format.html
          format.js do
            render :update do |page|
              flash.now[:error] = query.errors.full_messages
              page.replace_html('results', :partial => 'error')
            end
          end
        end
      
      ## Verify Query object existance
      else
        sql = "select * from queries where "

        if not query.q.nil? and not query.q.empty?
          sql << "q='" + query.q + "' "
        else
          sql << "q is null "
        end
        
        if not query.from_user.nil? and not query.from_user.empty?
          sql << "and from_user='" + query.from_user + "' "
        else
          sql << "and from_user is null "
        end
        
        if not query.lang.nil? and not query.lang.empty?
          sql << "and lang='" + query.lang + "' "
        else
          sql << "and lang is null "
        end
        
        sql << "and rpp='" + query.rpp.to_s + "' "        
        
        if not query.since.nil?
          sql << "and since=STR_TO_DATE('" + ("%d,%d,%d" % [query.since.day, query.since.month, query.since.year]) + "', '%d,%m,%Y') "
        else
          sql << "and since is null "
        end
        
        sql << "LIMIT 1;"
        
        ## If the Query object already exists in the table, update, otherwise
        # save a new entry
        existing_query = Query.find_by_sql(sql)[0]
        if not existing_query.nil?
          query = existing_query
        end
        
        begin
          @tweets = search_twitter(query)
          #puts @tweets.inspect
          
          ## Workaround: as the 'updated_at' is not being automatically
          # updated. Update forced.
          query.updated_at = Time.now
          query.save.to_s
          
          @queries = Query.find(:all, :order => 'updated_at DESC', :limit => 7)
          respond_to do |format|
            format.html
            format.js do
              render :update do |page|
                  flash.now[:notice] = "no tweets found!" if @tweets.empty?
                  page.replace_html('results', :partial => 'tweets')
                  page.replace_html('sidebar_contents', :partial => 'latest_queries')
                  if (not params[:from_search].nil?) and (params[:from_search].include?("latest"))
                    @query = query#Query.new
                    page.replace_html('search', :partial => 'advanced_search')
                  end
              end
            end
          end
        rescue
          respond_to do |format|
            format.html
            format.js do
              render :update do |page|
                @tweets = []
                @queries = Query.find(:all, :order => 'updated_at DESC', :limit => 7)
                flash.now[:error] = "query failed, try again later! :("
                page.replace_html('results', :partial => 'tweets')
                page.replace_html('sidebar_contents', :partial => 'latest_queries')
              end
            end
          end
        end
        
      end
    end
  end
  
  def simple_search
    if request.xhr?
      @query = Query.new
      render :partial => 'simple_search'
    end
  end
  
  def advanced_search
    if request.xhr?
      @query = Query.new
      render :partial => 'advanced_search'
    end
  end
  
end
