#!/usr/bin/env ruby
require 'httparty'

class NilClass
  def empty?
    true
  end
end

class GoDaddyDynDns

  C_URL = 'https://api.godaddy.com/'
  C_KEY = ''
  C_SECRET = ''
  C_NAME = ''
  C_PROVIDER = 'http://ifconfig.co/ip'

  C_HEADERS = {
    'Authorization': "sso-key #{C_KEY}:#{C_SECRET}",
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }

  def self.log(text)
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M')}]: #{text}"
  end

  def self.get_registered_ip
    endpoint = "v1/domains/solutioncottage.com/records/A/#{C_NAME}"
    full_url = C_URL + endpoint
    response = HTTParty.get(full_url, headers: C_HEADERS)
    if response.code.eql?(200)
      data = JSON.parse(response.body)
      return data.first['data'] if data.any?
    end
    return nil
  end

  def self.update_ip
    endpoint = "v1/domains/solutioncottage.com/records/A/#{C_NAME}"
    full_url = C_URL + endpoint
    external_ip = get_external_ip
    dns_ip = get_registered_ip

    if dns_ip.empty?
      log "DNS lookup failed for #{C_NAME}"
    elsif external_ip.empty?
      log "External IP lookup failed for #{C_NAME}"
    elsif dns_ip.eql?(external_ip)
      log "DNS IP and External IP are the same for #{C_NAME} (#{external_ip})"
    else
      data = [{ data: external_ip }]
      response = HTTParty.put(full_url, body: data.to_json, headers: C_HEADERS)
      if response.code.eql?(200)
        log "IP was successfully updated for #{C_NAME}! (#{external_ip})"
        return true
      else
        log "Failed to update IP for #{C_NAME}!"
      end
    end
    return false
  end

  def self.get_external_ip
    response = HTTParty.get(C_PROVIDER)
    response.code.eql?(200) ? response.body.delete("\n") : nil
  end


end

GoDaddyDynDns.update_ip
