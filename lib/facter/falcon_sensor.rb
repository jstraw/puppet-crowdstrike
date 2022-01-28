# Get the status of crowdstrike's falcon sensor

Facter.add(:falcon_sensor) do
  confine kernel: :Linux

  setcode do
    # invoke falconctl to get the current settings
    get_string = "/opt/CrowdStrike/falconctl -g --aid --apd --aph --app \
      --rfm-state --rfm-reason --version --tags"

    falcon_says = Facter::Util::Resolution.exec(get_string)

    if falcon_says
      falcon_sections = falcon_says.downcase.split(',')
      Facter.debug(falcon_sections)

      falcon_facts = {}
      falcon_sections.each do |l|
        line = l.strip
        Facter.debug(line)
        if line.length
          if line.include?('=') && !line.include?('version')
            data = line.split('=')
            Facter.debug(data)
            falcon_facts[data[0]] = data[1]
          else
            key = line.split[0]
            Facter.debug(key)
            if key == 'version'
              # There's no split between version and tag info, so we do some work here
              d = line.split('sensor')
              data = d[0].split(' = ')
              value = data[1]
              Facter.debug([key, value])
              falcon_facts[key] = value
              key = 'tags'
            end
            value = if line.include? 'not set'
                      nil
                    elsif line.include? 'true'
                      true
                    elsif line.include? 'false'
                      false
                    elsif line.include? 'are'
                      line.split('are')[1].split(',')
                    else
                      line
                    end
            Facter.debug([key, value])
            falcon_facts[key] = value
          end
        end
        falcon_facts.reject! { |_, v| v.nil? }
        Facter.debug(falcon_facts)
      end
      falcon_facts
    end
  end
end

# [root@1180952-Log-Relay1 ~]# /opt/CrowdStrike/falconctl -g --aid --apd --aph --app --rfm-state --rfm-reason --version --tags
# aid="bace43f9de594f479627b75adb54c294", apd is not set, aph is not set, app is not set, rfm-state=false, rfm-reason=None, code=0x0, version = 6.24.12104.0tags=SensorGroupingTags/ArmorLogRelay,
# aid is not set, apd is not set, aph is not set, app is not set, rfm-state=true, rfm-reason=Unspecified, code=0xC0000001, version = 5.34.9918.0Sensor grouping tags are not set,
# aid="cf1718c142684d90741fa49cd897da62", apd is not set, aph is not set, app is not set, rfm-state=false, rfm-reason=None, code=0x0, version = 6.22.11906.0Sensor grouping tags are not set,
