// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Traffic accounting exclusions for fwx (LAN-LAN, per-protocol, per-subnet/IP).
 */

#include <linux/inet.h>
#include <linux/kernel.h>
#include <linux/errno.h>

#include "fwx_stat_exclude.h"
#include "fwx_log.h"

int g_stat_exclude_lan_lan;
u32 g_stat_exclude_proto_mask;
struct fwx_exclude_net g_stat_exclude_nets[FWX_STAT_EXCLUDE_NET_MAX];
int g_stat_exclude_net_count;
DEFINE_SPINLOCK(g_stat_exclude_lock);

void fwx_stat_exclude_init(void)
{
	g_stat_exclude_lan_lan = 0;
	g_stat_exclude_proto_mask = 0;
	g_stat_exclude_net_count = 0;
	memset(g_stat_exclude_nets, 0, sizeof(g_stat_exclude_nets));
}

static __be32 fwx_inet_prefix_to_mask(int plen)
{
	if (plen <= 0)
		return 0;
	if (plen >= 32)
		return htonl(0xffffffffu);
	return htonl(~((1u << (32 - plen)) - 1));
}

static int fwx_parse_cidr(const char *s, struct fwx_exclude_net *out)
{
	char buf[128];
	char *slash;
	size_t ip_len;
	int plen = 32;
	u8 addr_bin[4];

	if (!s || !*s)
		return -EINVAL;

	strncpy(buf, s, sizeof(buf) - 1);
	buf[sizeof(buf) - 1] = '\0';
	slash = strchr(buf, '/');
	if (slash) {
		*slash = '\0';
		plen = (int)simple_strtol(slash + 1, NULL, 10);
		if (plen < 0 || plen > 32)
			return -EINVAL;
	}

	ip_len = strlen(buf);
	if (ip_len == 0 || !in4_pton(buf, ip_len, addr_bin, -1, NULL))
		return -EINVAL;

	memcpy(&out->addr, addr_bin, 4);
	out->mask = fwx_inet_prefix_to_mask(plen);
	return 0;
}

static int addr_in_net(__be32 ip, const struct fwx_exclude_net *n)
{
	return (ip & n->mask) == (n->addr & n->mask);
}

/* true when both IPv4 endpoints are on the configured main LAN (br-lan / lan_ip+mask) */
static int fwx_both_in_main_lan(__be32 saddr, __be32 daddr)
{
	if (!fwx_lan_ip || !fwx_lan_mask)
		return 0;
	return ((saddr & fwx_lan_mask) == (fwx_lan_ip & fwx_lan_mask)) &&
	       ((daddr & fwx_lan_mask) == (fwx_lan_ip & fwx_lan_mask));
}

int fwx_stat_flow_excluded(__be32 saddr, __be32 daddr, u8 proto)
{
	int i;
	u32 pm;
	int excl_lan;
	int lan_lan;

	if (!g_stat_exclude_lan_lan && !g_stat_exclude_proto_mask && g_stat_exclude_net_count == 0)
		return 0;

	spin_lock_bh(&g_stat_exclude_lock);

	lan_lan = fwx_both_in_main_lan(saddr, daddr);

	excl_lan = g_stat_exclude_lan_lan;
	if (excl_lan && lan_lan) {
		spin_unlock_bh(&g_stat_exclude_lock);
		return 1;
	}

	/* Protocol mask: only skip stats for LAN<->LAN; LAN<->WAN still counted */
	pm = g_stat_exclude_proto_mask;
	if (lan_lan && pm && (pm & (1u << proto))) {
		spin_unlock_bh(&g_stat_exclude_lock);
		return 1;
	}

	for (i = 0; i < g_stat_exclude_net_count; i++) {
		if (addr_in_net(saddr, &g_stat_exclude_nets[i]) ||
		    addr_in_net(daddr, &g_stat_exclude_nets[i])) {
			spin_unlock_bh(&g_stat_exclude_lock);
			return 1;
		}
	}

	spin_unlock_bh(&g_stat_exclude_lock);
	return 0;
}

int fwx_api_set_traffic_stat_exclude(cJSON *data_obj)
{
	cJSON *o;
	int i;
	int cnt = 0;

	if (!data_obj)
		return -EINVAL;

	spin_lock_bh(&g_stat_exclude_lock);

	o = cJSON_GetObjectItem(data_obj, "exclude_lan_lan");
	if (o && (o->type == cJSON_True || o->type == cJSON_False))
		g_stat_exclude_lan_lan = (o->type == cJSON_True) ? 1 : 0;
	else if (o && o->type == cJSON_Number)
		g_stat_exclude_lan_lan = o->valueint ? 1 : 0;

	o = cJSON_GetObjectItem(data_obj, "exclude_proto_mask");
	if (o && o->type == cJSON_Number)
		g_stat_exclude_proto_mask = (u32)o->valueint;

	memset(g_stat_exclude_nets, 0, sizeof(g_stat_exclude_nets));
	g_stat_exclude_net_count = 0;

	o = cJSON_GetObjectItem(data_obj, "exclude_nets");
	if (o && o->type == cJSON_Array) {
		int n = cJSON_GetArraySize(o);

		for (i = 0; i < n && cnt < FWX_STAT_EXCLUDE_NET_MAX; i++) {
			cJSON *item = cJSON_GetArrayItem(o, i);

			if (!item || item->type != cJSON_String || !item->valuestring)
				continue;
			if (fwx_parse_cidr(item->valuestring, &g_stat_exclude_nets[cnt]) == 0)
				cnt++;
		}
	}
	g_stat_exclude_net_count = cnt;

	spin_unlock_bh(&g_stat_exclude_lock);
	return 0;
}
