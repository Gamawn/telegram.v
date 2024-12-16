module telegram

import os
import thomaspeissl.dotenv
import rand

__global (
	test_token = ''
	test_chat  = ''
)

fn testsuite_begin() {
	dotenv.load()
	test_token = os.getenv('TELEGRAM_BOT_TOKEN')
	test_chat = os.getenv('TELEGRAM_TEST_CHAT_ID')
}

fn test_new_client() {
	client := new_client(test_token)
	assert client.api_token == test_token
	assert client.base_url == 'https://api.telegram.org/bot${test_token}'
}

fn test_get_me() {
	if test_token == '' {
		eprintln('Skipping test_get_me: TELEGRAM_BOT_TOKEN not set')
		return
	}

	client := new_client(test_token)
	response := client.get_me() or {
		assert false, 'get_me failed: ${err}'
		return
	}

	assert response.ok == true
	assert response.description == ''
	assert response.result.len == 0
}

fn test_send_message() {
	if test_token == '' || test_chat == '' {
		eprintln('Skipping test_send_message: TELEGRAM_BOT_TOKEN or TELEGRAM_TEST_CHAT_ID not set')
		return
	}

	client := new_client(test_token)
	test_message := 'Test message from V Telegram API client'

	response := client.send_message(test_chat, test_message) or {
		assert false, 'send_message failed: ${err}'
		return
	}

	assert response.ok == true
	assert response.description == ''
	assert response.result.len == 0
}

fn test_invalid_token() {
	invalid_bot_id := rand.i32_in_range(1, 100000)!
	invalid_token := rand.string(32)
	client := new_client('${invalid_bot_id}:${invalid_token}')
	response := client.get_me() or {
		eprint(err)
		assert err.msg().contains('401'), 'Expected 401 error for invalid token'
		return
	}
	assert false, 'Expected error for invalid token'
}

fn test_empty_message() {
	if test_token == '' || test_chat == '' {
		eprintln('Skipping test_empty_message: TELEGRAM_BOT_TOKEN or TELEGRAM_TEST_CHAT_ID not set')
		return
	}

	client := new_client(test_token)
	response := client.send_message(test_chat, '') or {
		print(err.msg())
		assert err.msg().contains('empty'), 'Expected error for empty message'
		return
	}
	assert false, 'Expected error for empty message'
}
