# frozen_string_literal: true

module RSpec
  module Puppet
    module Win32
      class Registry
        module Constants
          HKEY_CLASSES_ROOT = 0x80000000
          HKEY_CURRENT_USER = 0x80000001
          HKEY_LOCAL_MACHINE = 0x80000002
          HKEY_USERS = 0x80000003
          HKEY_PERFORMANCE_DATA = 0x80000004
          HKEY_PERFORMANCE_TEXT = 0x80000050
          HKEY_PERFORMANCE_NLSTEXT = 0x80000060
          HKEY_CURRENT_CONFIG = 0x80000005
          HKEY_DYN_DATA = 0x80000006

          REG_NONE = 0
          REG_SZ = 1
          REG_EXPAND_SZ = 2
          REG_BINARY = 3
          REG_DWORD = 4
          REG_DWORD_LITTLE_ENDIAN = 4
          REG_DWORD_BIG_ENDIAN = 5
          REG_LINK = 6
          REG_MULTI_SZ = 7
          REG_RESOURCE_LIST = 8
          REG_FULL_RESOURCE_DESCRIPTOR = 9
          REG_RESOURCE_REQUIREMENTS_LIST = 10
          REG_QWORD = 11
          REG_QWORD_LITTLE_ENDIAN = 11

          STANDARD_RIGHTS_READ = 0x00020000
          STANDARD_RIGHTS_WRITE = 0x00020000
          KEY_QUERY_VALUE = 0x0001
          KEY_SET_VALUE = 0x0002
          KEY_CREATE_SUB_KEY = 0x0004
          KEY_ENUMERATE_SUB_KEYS = 0x0008
          KEY_NOTIFY = 0x0010
          KEY_CREATE_LINK = 0x0020
          KEY_READ = STANDARD_RIGHTS_READ |
                     KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | KEY_NOTIFY
          KEY_WRITE = STANDARD_RIGHTS_WRITE |
                      KEY_SET_VALUE | KEY_CREATE_SUB_KEY
          KEY_EXECUTE = KEY_READ
          KEY_ALL_ACCESS = KEY_READ | KEY_WRITE | KEY_CREATE_LINK

          REG_OPTION_RESERVED = 0x0000
          REG_OPTION_NON_VOLATILE = 0x0000
          REG_OPTION_VOLATILE = 0x0001
          REG_OPTION_CREATE_LINK = 0x0002
          REG_OPTION_BACKUP_RESTORE = 0x0004
          REG_OPTION_OPEN_LINK = 0x0008
          REG_LEGAL_OPTION = REG_OPTION_RESERVED |
                             REG_OPTION_NON_VOLATILE | REG_OPTION_CREATE_LINK |
                             REG_OPTION_BACKUP_RESTORE | REG_OPTION_OPEN_LINK

          REG_CREATED_NEW_KEY = 1
          REG_OPENED_EXISTING_KEY = 2

          REG_WHOLE_HIVE_VOLATILE = 0x0001
          REG_REFRESH_HIVE = 0x0002
          REG_NO_LAZY_FLUSH = 0x0004
          REG_FORCE_RESTORE = 0x0008

          MAX_KEY_LENGTH = 514
          MAX_VALUE_LENGTH = 32_768
        end
        include Constants
      end
    end
  end
end

begin
  require 'win32/registry'
rescue LoadError
  module Win32
    Registry = RSpec::Puppet::Win32::Registry
  end
end
