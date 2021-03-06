# generated by agent_generator.rb, manual changes will be lost

class pacemaker::stonith::fence_scsi (
	$aptpl = undef,
	$devices = undef,
	$logfile = undef,
	$delay = undef,
	$key = undef,
	$nodename = undef,

	$interval = "60s",
	$ensure = present,
	$pcmk_host_value = undef,

) {
  $real_address = "$(corosync-cfgtool -a $(crm_node -n))"

  if($ensure == absent) {
    exec {
      "Removing stonith::fence_scsi":
      command => "/usr/sbin/pcs stonith delete stonith-fence_scsi-${real_address}",
      onlyif => "/usr/sbin/pcs stonith show stonith-fence_scsi-${real_address} > /dev/null 2>&1",
      require => Class["pacemaker::corosync"],
    }
  } else {
  	$aptpl_chunk = $aptpl ? {
		undef => "",
		default => "aptpl=\"${aptpl}\"",
	}
	$devices_chunk = $devices ? {
		undef => "",
		default => "devices=\"${devices}\"",
	}
	$logfile_chunk = $logfile ? {
		undef => "",
		default => "logfile=\"${logfile}\"",
	}
	$delay_chunk = $delay ? {
		undef => "",
		default => "delay=\"${delay}\"",
	}
	$key_chunk = $key ? {
		undef => "",
		default => "key=\"${key}\"",
	}
	$nodename_chunk = $nodename ? {
		undef => "",
		default => "nodename=\"${nodename}\"",
	}

    $pcmk_host_value_chunk = $pcmk_host_list ? {
      '' => '$(/usr/sbin/crm_node -n)',
      default => "${pcmk_host_list}",
    }

    package {
      "fence-agents-scsi": ensure => installed,
    } -> exec {
      "Creating stonith::fence_scsi":
      command => "/usr/sbin/pcs stonith create stonith-fence_scsi-${real_address} fence_scsi pcmk_host_list=\"${pcmk_host_value_chunk}\" ${aptpl_chunk} ${devices_chunk} ${logfile_chunk} ${delay_chunk} ${key_chunk} ${nodename_chunk}  op monitor interval=${interval}",
      unless => "/usr/sbin/pcs stonith show stonith-fence_scsi-${real_address} > /dev/null 2>&1",
      require => Class["pacemaker::corosync"],
    } -> exec {
      "Adding non-local constraint stonith::fence_scsi ${real_address}":
      command => "/usr/sbin/pcs constraint location stonith-fence_scsi-${real_address} avoids ${pcmk_host_value_chunk}"
    }
  }
}
