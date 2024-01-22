#!/usr/bin/env ruby

# Hack-n-test script for the eschol API

# Use bundler to keep dependencies local
require 'rubygems'
require 'bundler/setup'

require 'httparty'

# API URL should be set in an environment variable
$api_url = ENV['ESCHOL_API_URL']

#################################################################################################
# Send a GraphQL query to the eschol API, returning the JSON results.
def apiQuery(query, vars = {}, privileged = false)
  if vars.empty?
    query = "query { #{query} }"
  else
    query = "query(#{vars.map{|name, pair| "$#{name}: #{pair[0]}"}.join(", ")}) { #{query} }"
  end
  varHash = Hash[vars.map{|name,pair| [name.to_s, pair[1]]}]
  headers = { 'Content-Type' => 'application/json' }
  privKey = ENV['ESCHOL_PRIV_API_KEY'] or raise("missing env ESCHOL_PRIV_API_KEY")
  privileged and headers['Privileged'] = privKey
  response = HTTParty.post($api_url, :headers => headers, :body => { variables: varHash, query: query }.to_json)
  response.code == 200 or raise("Internal error (graphql): HTTP code #{response.code}")
  response['errors'] and raise("Internal error (graphql): #{response['errors'][0]['message']}")
  response['data']
end

#################################################################################################
# Send a GraphQL query to the eschol API, returning the JSON results.
def apiMutation(mutation, vars)
  query = "mutation(#{vars.map{|name, pair| "$#{name}: #{pair[0]}"}.join(", ")}) { #{mutation} }"
  varHash = Hash[vars.map{|name,pair| [name.to_s, pair[1]]}]
  headers = { 'Content-Type' => 'application/json' }
  headers['Privileged'] = ENV['ESCHOL_PRIV_API_KEY'] or raise("missing env ESCHOL_PRIV_API_KEY")
  response = HTTParty.post($api_url, :headers => headers, :body => { variables: varHash, query: query }.to_json)
  response.code == 200 or raise("Internal error (graphql): HTTP code #{response.code}")
  response['errors'] and raise("Internal error (graphql): #{response['errors'][0]['message']}")
  response['data']
end

#################################################################################################

result = apiQuery("item(id: $itemID) { title }", { itemID: ["ID!", "ark:/13030/qt99m5j3q7"] })
title = result["item"]["title"]
if title != "Onboard Feedback to Promote Eco-Driving: Average Impact and Important Features"
  puts "failed: get item #{title}"
  puts result
else
  puts "success: get item"
end

result = apiQuery("rootUnit{id}", {})
if result["rootUnit"]["id"] != "root"
  puts "failed: get root unit"
  puts result
else
  puts "success: get root unit"
end

result = apiQuery("item(id: $itemID) { suppFiles{ size } }", {itemID: ["ID!", "ark:/13030/qt7sd5267g"]})
if result["item"]["suppFiles"].length == 6
  puts "success: get large file size"
else
  puts "failed: get large file size"
  puts result
end

result = apiQuery("item(id: $itemID) { id status }", {itemID: ["ID!", "ark:/13030/qt8k5278rr"]})
if result["item"]["status"] == "PENDING"
  puts "success: status pending"
else
  puts "failed: status pending"
  puts result
end

result = apiMutation("depositItem(input: $input) { id message }", {input: ["DepositItemInput!", {id: "ark:/13030/qtXXXXXXXX", sourceName: "janeway", sourceID: "10", submitterEmail: "a@b.c", title: "Test Title", type: "ARTICLE", published: "2020-12-20", isPeerReviewed: true, units: ['ucm']}]})
if result["depositItem"]["message"].index("ERROR") == 0
   puts "success: update non-existant"
else
  puts "failed: update non-existant"
  puts result
end

result = apiMutation("mintProvisionalID(input: $input) { id }", { input: ["MintProvisionalIDInput!", { sourceName: "elements", sourceID: "abc123" } ] })
if result["mintProvisionalID"]["id"].index("ark:/13030/qt") == 0
  puts "success: mint provisional id"
else
  puts "failed: mint provisional id"
  puts result
end
