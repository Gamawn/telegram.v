module telegram

import net.http
import json

pub struct TelegramClient {
mut:
	api_token string
	base_url  string
}

// Response represents a basic Telegram API response
pub struct ApiResponse {
pub mut:
	ok          bool
	description string
	result      string // This will be parsed based on the specific method
}

// Error type for Telegram API errors
pub struct TelegramError {
pub:
	code    int
	message string
}

// Create new instance of TelegramClient
pub fn new_client(token string) TelegramClient {
	return TelegramClient{
		api_token: token
		base_url:  'https://api.telegram.org/bot${token}'
	}
}

// make_request performs the HTTP request to Telegram API
pub fn (client TelegramClient) make_request(method string, params map[string]string) !ApiResponse {
	url := '${client.base_url}/${method}'

	// Create request configuration
	mut config := http.FetchConfig{
		method: .post
		header: http.new_header(
			key:   .content_type
			value: 'application/json'
		)
		url:    url
	}

	// Convert params to JSON
	data := json.encode(params)
	config.data = data

	// Perform request
	response := http.fetch(config) or { return error('Failed to make request: ${err}') }

	// Check HTTP status
	if response.status_code != 200 {
		return error('HTTP error: ${response.status_code} - ${response.status_msg}')
	}

	// Parse response
	mut api_response := json.decode(ApiResponse, response.body) or {
		return error('Failed to decode response: ${err}')
	}

	if !api_response.ok {
		return error(api_response.description)
	}

	return api_response
}

// Example method: getMe
pub fn (client TelegramClient) get_me() !ApiResponse {
	return client.make_request('getMe', map[string]string{})
}

// Example method: sendMessage
pub fn (client TelegramClient) send_message(chat_id string, text string) !ApiResponse {
	if text.len == 0 {
		return error('body of message should not be empty')
	}

	params := {
		'chat_id': chat_id
		'text':    text
	}

	return client.make_request('sendMessage', params)
}
