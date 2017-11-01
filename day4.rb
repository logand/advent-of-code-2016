require "pry"
# --- Day 4: Security Through Obscurity ---
#
# Finally, you come across an information kiosk with a list of rooms. Of course, the list is encrypted and full of decoy data, but the instructions to decode the list are barely hidden nearby. Better remove the decoy data first.
#
# Each room consists of an encrypted name (lowercase letters separated by dashes) followed by a dash, a sector ID, and a checksum in square brackets.
#
# A room is real (not a decoy) if the checksum is the five most common letters in the encrypted name, in order, with ties broken by alphabetization. For example:
#
# aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters are a (5), b (3), and then a tie between x, y, and z, which are listed alphabetically.
# a-b-c-d-e-f-g-h-987[abcde] is a real room because although the letters are all tied (1 of each), the first five are listed alphabetically.
# not-a-real-room-404[oarel] is a real room.
# totally-real-room-200[decoy] is not.
# Of the real rooms from the list above, the sum of their sector IDs is 1514.
#
# What is the sum of the sector IDs of the real rooms?

def make_room(room_name)
  matches = /([^\d]*)-(\d*)\[(.*)\]/.match(room_name)
  room = { name: matches[1], sector_id: matches[2].to_i, checksum: matches[3] }
  room[:frequencies] = generate_frequencies(room[:name])
  room
end

def generate_frequencies(room_name)
  freq_map = {}
  room_name.split("").each do |char|
    if char != '-'
      if freq_map[char] == nil
        freq_map[char] = 1
      else
        freq_map[char] += 1
      end
    end
  end

  frequencies = []
  freq_map.keys.each do |char|
    frequencies.push([char, freq_map[char]])
  end

  frequencies.sort do |a,b|
    if a[1] != b[1]
      a[1] < b[1] ? 1 : -1
    else
      a[0] < b[0] ? -1 : 1
    end
  end
end

def is_real_room?(room)
  room[:checksum].split("").each_with_index do |char, index|
    if char != room[:frequencies][index][0]
      return false
    end
  end
  true
end

sector_id_sum = 0

rooms = File.open("data/rooms.txt").map { |room_string| make_room(room_string) }

real_rooms = rooms.select { |room| is_real_room? room }

real_rooms.each { |room| sector_id_sum += room[:sector_id] }

puts "The sum of the #{real_rooms.length} real rooms sector ids is: #{sector_id_sum}"

# --- Part Two ---
#
# With all the decoy data out of the way, it's time to decrypt this list and get moving.
#
# The room names are encrypted by a state-of-the-art shift cipher, which is nearly unbreakable without the right software. However, the information kiosk designers at Easter Bunny HQ were not expecting to deal with a master cryptographer like yourself.
#
# To decrypt a room name, rotate each letter forward through the alphabet a number of times equal to the room's sector ID. A becomes B, B becomes C, Z becomes A, and so on. Dashes become spaces.
#
# For example, the real name for qzmt-zixmtkozy-ivhz-343 is very encrypted name.
#
# What is the sector ID of the room where North Pole objects are stored?

def rotate(name, rotation)
  alphabet = ('a'..'z').to_a
  rot = rotation % 26
  decrypted = name.split("").map do |char|
                if char == "-"
                  " "
                else
                  i = alphabet.index(char)
                  # puts "char: #{char} index: #{i}"
                  letter = (i + rot) % 26
                  alphabet[letter]
                end
              end
  decrypted.join("")
end

real_sector_id = ""

real_rooms.each do |room|
  room[:decrypted_name] = rotate(room[:name], room[:sector_id])
  if room[:decrypted_name] == "northpole object storage"
    real_sector_id = room[:sector_id]
  end
end

puts "The sector ID of the room called north pole objects is #{real_sector_id}"
