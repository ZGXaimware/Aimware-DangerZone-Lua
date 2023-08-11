from flask import Flask
import keyboard
import time
import threading

app = Flask(__name__)

# Change all 'g' in this function with your lag exploit key.
def hold_key():
    keyboard.press('page down')
    time.sleep(0.2)
    keyboard.release('page down')

@app.route('/', methods=['GET'])
def press_and_release_key():
    t = threading.Thread(target=hold_key)
    t.start()
    return '!'

if __name__ == '__main__':
    app.run("127.0.0.69")