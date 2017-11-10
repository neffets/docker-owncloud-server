#!/usr/bin/env bash

phpenmod imap
occ check && occ app:enable user_external

