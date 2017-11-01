require "pry"

def make_room(room_name)
  room = {}
  room[:checksum] = /\[(.*)\]/.match(room_name)[1]
  room[:sector_id] = /-(\d*)\[/.match(room_name)[1].to_i
  room[:name] = /([^\d]*)-/.match(room_name)[1]
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
    if a[1] < b[1]
      1
    elsif a[1] > b[1]
      -1
    else
      if a[0] < b[0]
        -1
      else
        1
      end
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

puts sector_id_sum

# Part 2

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
  # puts "#{room[:sector_id]} #{room[:decrypted_name]}"
end

puts real_sector_id
