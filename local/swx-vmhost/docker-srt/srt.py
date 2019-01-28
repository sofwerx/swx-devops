"""Using Python's built-in HTTPServer"""
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import json

class SrtHttpServer(BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(200)
    self.send_header("Content-type", "application/json")
    self.end_headers()
    srt_tcp_response = { 'version': '1.0' }
    if 'SRT_URL' in os.environ:
      srt_tcp_response['url'] = os.environ['SRT_URL']
    if 'SRT_PASSPHRASE' in os.environ:
      srt_tcp_response['passphrase'] = os.environ['SRT_PASSPHRASE']
    if 'SRT_KEY_LENGTH' in os.environ:
      srt_tcp_response['key_length'] = os.environ['SRT_KEY_LENGTH']
    srt_tcp_response_string = str(json.dumps(srt_tcp_response)).encode()
    self.wfile.write(srt_tcp_response_string)

if __name__ == "__main__":
  port = int(os.getenv('SRT_PORT','5000'))
  print("Listening on 0.0.0.0:" + str(port))
  HTTPServer(("0.0.0.0", port), SrtHttpServer).serve_forever()
