function vpntest
    curl -x socks5h://127.0.0.1:12334 -o /dev/null -s -w 'delay: %{time_total}s\n' http://cp.cloudflare.com/generate_204
end
