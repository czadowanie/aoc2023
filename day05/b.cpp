#include <algorithm>
#include <cinttypes>
#include <iostream>
#include <istream>
#include <optional>
#include <ostream>
#include <thread>
#include <vector>

struct SeedRange {
  uint32_t begin;
  uint32_t end;
};

struct Mapping {
  // ie. 5 8 2
  // src_begin = 5
  // src_end = 7
  // dst_begin = 8
  // (dst_end = 10)

  uint32_t src_begin;
  uint32_t src_end;
  uint32_t dst_begin;

  Mapping(uint32_t src, uint32_t dst, uint32_t len)
      : src_begin(src), src_end(src + len), dst_begin(dst) {}

  bool map(uint32_t &val) const {
    if (val < src_begin or val >= src_end) {
      return false;
    } else {
      uint32_t pos = val - src_begin;
      val = dst_begin + pos;
      return true;
    }
  }
};

struct MappingSet {
  std::vector<Mapping> mappings{};

  uint32_t map(uint32_t src) const {
    for (const auto &mapping : mappings) {
      uint32_t val = src;
      if (mapping.map(val)) {
        return val;
      }
    }

    return src;
  }
};

struct Almanac {
  std::vector<SeedRange> seeds{};
  std::vector<MappingSet> mappings{};

  void print() const {
    printf("seeds:\n");
    for (auto seed : seeds) {
      printf("%u..%u\n", seed.begin, seed.end);
    }

    printf("mappings:\n");
    for (const auto &set : mappings) {
      printf("  SET\n");
      for (const auto &mapping : set.mappings) {
        printf("    %u..%u -> %u..%u\n", mapping.src_begin, mapping.src_end,
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
    uint32_t start, len;
    sscanf(&(*it), "%u %u ", &start, &len);

    for (int i = 0; i < 2; i++) {
      while (isdigit(*it)) {
        it++;
      }
      if (*it == ' ') {
        it++;
      }
    }

    almanac.seeds.push_back(SeedRange{start, start + len});
  }

  while (std::getline(std::cin, line)) {
    if (line.size() == 0) {
      continue;
    } else if (!isdigit(line[0])) {
      almanac.mappings.push_back(MappingSet{});
    } else {
      uint32_t src, dst, len;
      sscanf(line.c_str(), "%u %u %u", &dst, &src, &len);
      almanac.mappings[almanac.mappings.size() - 1].mappings.push_back(
          Mapping(src, dst, len));
    }
  }

  almanac.print();

  printf("\nsearching...\n");

  std::vector<uint32_t> locations{};
  uint32_t min_location = UINT32_MAX;

  const size_t nthreads = std::thread::hardware_concurrency();
  printf("nthreads: %lu\n", nthreads);

  for (auto seedrange : almanac.seeds) {
    printf("searching %u..%u, len = %u\n", seedrange.begin, seedrange.end,
           seedrange.end - seedrange.begin);

    const uint32_t seedrange_len = seedrange.end - seedrange.begin;
    const uint32_t window_size = seedrange_len / nthreads;
    const uint32_t remaining = seedrange_len % nthreads;

    std::vector<std::thread> threads{};
    threads.reserve(nthreads);
    std::vector<uint32_t> min_locations{};
    min_locations.reserve(nthreads);

    for (size_t i = 0; i < nthreads; i++) {
      min_locations.push_back(UINT32_MAX);
    }

    for (size_t i = 0; i < nthreads; i++) {
      const uint32_t begin = seedrange.begin + (window_size * i);
      const uint32_t end =
          begin + window_size + ((i == nthreads - 1) ? remaining : 0);

      uint32_t *min_loc = &min_locations[i];

      threads.push_back(std::thread([&almanac, begin, end, min_loc]() -> void {
        uint32_t ml = *min_loc;

        for (uint32_t seed = begin; seed < end; seed++) {
          const auto soil = almanac.mappings[0].map(seed);
          const auto fertilizer = almanac.mappings[1].map(soil);
          const auto water = almanac.mappings[2].map(fertilizer);
          const auto light = almanac.mappings[3].map(water);
          const auto temperature = almanac.mappings[4].map(light);
          const auto humidity = almanac.mappings[5].map(temperature);
          const auto location = almanac.mappings[6].map(humidity);

          const bool bsmaller = location < ml;
          const uint32_t lt = static_cast<uint32_t>(bsmaller);
          const uint32_t gte = static_cast<uint32_t>(!bsmaller);
          ml = lt * location + gte * ml;
        }

        *min_loc = ml;
      }));
    }

    for (size_t i = 0; i < nthreads; i++) {
      threads[i].join();
      min_location = std::min(min_location, min_locations[i]);
    }

    printf("DONE\n");
  }

  printf("answer: %u\n", min_location);

  return 0;
}
