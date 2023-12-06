#include <algorithm>
#include <cinttypes>
#include <iostream>
#include <istream>
#include <optional>
#include <ostream>
#include <vector>

struct Mapping {
  // ie. 5 8 2
  // src_begin = 5
  // src_end = 7
  // dst_begin = 8
  // (dst_end = 10)

  uint64_t src_begin;
  uint64_t src_end;
  uint64_t dst_begin;

  Mapping(uint64_t src, uint64_t dst, uint64_t len)
      : src_begin(src), src_end(src + len), dst_begin(dst) {}

  std::optional<uint64_t> map(uint64_t val) const {
    if (val < src_begin or val >= src_end) {
      return std::nullopt;
    } else {
      uint64_t pos = val - src_begin;
      return dst_begin + pos;
    }
  }
};

struct MappingSet {
  std::vector<Mapping> mappings{};

  uint64_t map(uint64_t src) const {
    for (const auto &mapping : mappings) {
      auto res = mapping.map(src);
      if (res) {
        return res.value();
      }
    }

    return src;
  }
};

struct Almanac {
  std::vector<uint64_t> seeds{};
  std::vector<MappingSet> mappings{};

  void print() const {
    printf("seeds:\n");
    for (auto seed : seeds) {
      printf("%lu\n", seed);
    }

    printf("mappings:\n");
    for (const auto &set : mappings) {
      printf("  SET\n");
      for (const auto &mapping : set.mappings) {
        printf("    %lu..%lu -> %lu..%lu\n", mapping.src_begin, mapping.src_end,
               mapping.dst_begin,
               mapping.dst_begin + (mapping.src_end - mapping.src_begin));
      }
    }
  }
};

int main() {
  auto almanac = Almanac{};

  std::string line;

  std::getline(std::cin, line);
  for (auto it = line.cbegin() + sizeof("seeds:"); it != line.cend();) {
    auto number_len = static_cast<size_t>(
        std::find_if(it, line.cend(),
                     [](char c) -> bool { return c == ' ' or c == '\n'; }) -
        it);

    uint64_t number = atoi(&(*it));

    almanac.seeds.push_back(number);

    it += number_len;
    if (*it == ' ') {
      it += 1;
    }
  }

  while (std::getline(std::cin, line)) {
    if (line.size() == 0) {
      continue;
    } else if (!isdigit(line[0])) {
      almanac.mappings.push_back(MappingSet{});
    } else {
      uint64_t src, dst, len;
      sscanf(line.c_str(), "%lu %lu %lu", &dst, &src, &len);
      almanac.mappings[almanac.mappings.size() - 1].mappings.push_back(
          Mapping(src, dst, len));
    }
  }

  almanac.print();

  std::vector<uint64_t> locations{};
  for (auto seed : almanac.seeds) {
    auto soil = almanac.mappings[0].map(seed);
    printf("seed %lu -> soil %lu\n", seed, soil);
    auto fertilizer = almanac.mappings[1].map(soil);
    printf("soil %lu -> fertilizer %lu\n", soil, fertilizer);
    auto water = almanac.mappings[2].map(fertilizer);
    printf("fertilizer %lu -> water %lu\n", fertilizer, water);
    auto light = almanac.mappings[3].map(water);
    printf("water %lu -> light %lu\n", water, light);
    auto temperature = almanac.mappings[4].map(light);
    printf("light %lu -> temperature %lu\n", light, temperature);
    auto humidity = almanac.mappings[5].map(temperature);
    printf("temperature %lu -> humidity %lu\n", temperature, humidity);
    auto location = almanac.mappings[6].map(humidity);
    printf("humidity %lu -> location %lu\n", humidity, location);
    printf("\n");

    locations.push_back(location);
  }

  auto min_location = *std::min_element(locations.cbegin(), locations.cend());

  printf("answer: %lu\n", min_location);

  return 0;
}
