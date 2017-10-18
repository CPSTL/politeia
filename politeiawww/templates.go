// Copyright (c) 2017 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

package main

const templateEmailRaw = `
<div>Click the link below to verify your email and complete your registration:</div>
<div style="margin: 20px 0 0 10px"><a href="{{.Link}}">{{.Link}}</a></div>
<div style="margin-top: 20px">You are receiving this email because
<span style="font-weight: bold">{{.Email}}</span> was used to register for Politeia.</div>
`
