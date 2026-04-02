/* SPDX-License-Identifier: GPL-2.0-or-later */
#ifndef FWX_STAT_EXCLUDE_H
#define FWX_STAT_EXCLUDE_H

#include "k_json.h"
#include <linux/types.h>
#include <linux/spinlock.h>

#define FWX_STAT_EXCLUDE_NET_MAX 24

struct fwx_exclude_net {
	__be32 addr;
	__be32 mask;
};

extern int g_stat_exclude_lan_lan;
extern u32 g_stat_exclude_proto_mask;
extern struct fwx_exclude_net g_stat_exclude_nets[FWX_STAT_EXCLUDE_NET_MAX];
extern int g_stat_exclude_net_count;
extern spinlock_t g_stat_exclude_lock;

void fwx_stat_exclude_init(void);
int fwx_stat_flow_excluded(__be32 saddr, __be32 daddr, u8 proto);
int fwx_api_set_traffic_stat_exclude(cJSON *data_obj);

#endif
