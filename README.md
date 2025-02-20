# Replicate issue

Host reacheable only via a proxy fail if client certificates options are not empty.

## Dependencies

- Node.js >= 20
- Playwright 1.50.0

## Steps to run

1. make check-etc-hosts
1. make run

This will:

- Run tiny proxy with docker. A /etc/hosts file is mounted to resolve fake.example.com to httpbin.org, just to make it routable.
- Install playwright 1.50.1
- Run main.js.
  - This will open fake.example.com in a new browser with 2 different configurations:
    - Using proxy and adding a client certificate configuration to an unrelated domain.
    - Using proxy and not adding any client certificate configuration.

## Expected result

- The page is loaded successfully in both cases.

## Actual result

- The page is loaded successfully only when not specifying any client certificate configuration.

## Reason

Using any client certificate configuration, playwright adds a dummy server. In order to set it up, it tries to detect the available protocols from the target server (ALPN). However, the APNS part does not use the proxy.

If the host does not resolve, ALPNCache errors fast and assumes http/1.1. Not the expected behavior but at least it works for cases where http 1.1 is the expected protocol.


