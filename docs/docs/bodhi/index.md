---
title: "Bodhi Ecosystem"
slug: "/bodhi"
hidden: false
sidebar_position: 15
hide_table_of_contents: true

---

# Bodhi Ecosystem

Bodhi is a protocol that tokenize the object.

Bodhi 是一个对客体代币化的协议。

> https://bodhi.wtf

See the bodhi projects panel:

> https://projects.noncegeek.com/?tag=bodhi

## 0x01 Bodhi Open APIs

Bodhi Open APIs are free APIs that maintained by rootMUD Community, the lightweight backend is powered by Supabase & Deno.

Here are the source code for the backend:

> https://github.com/NonceGeek/bodhi-searcher/blob/main/deno_edge_functions/bodhi_data_getter.tsx

C0ntact with us if you are buidling something on Bodhi:

> https://t.me/leeduckgo

### 1.1 get asset_index_latest

**url:** https://bodhi-data.deno.dev/assets_index_latest

**description:** get the latest index for the assets.

### 1.2 get assets

**url:** https://bodhi-data.deno.dev/assets?asset_begin=0&asset_end=20

**description:** get asset information by the asset_id.

### 1.3 text_search

**url:** https://bodhi-data.deno.dev/text_search?table_name=bodhi_text_assets&column=content&keyword=bitcoin

**description:** search assets by the keyword.

<!-- ### 1.4 bodhi_auth

**url:** https://bodhi-data.deno.dev/bodhi_auth?addr={addr}&msg={msg}&signature={signature}& -->