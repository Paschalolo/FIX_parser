
#define  _DEFAULT_SOURCE
#include <sys/mman.h>
#include <linux/mman.h>
#include <fcntl.h>
#include <cstdio>
#include <cstdlib>
#include <cstdint>


extern "C" int parse_impl(void* payload_addr , void* parsed_addr , size_t sz );


class alignas(64) FIX_Payload_Parser{
	private : 
		void* m_payload_addr_; 
		void* m_parsed_addr_ ;
		size_t m_parsed_sz_;
	public:
		FIX_Payload_Parser(void* payload_addr , size_t sz) noexcept;
		~FIX_Payload_Parser();
		inline __attribute__((always_inline)) int  parse(){
			return parse_impl(m_payload_addr_ , m_parsed_addr_ , m_parsed_sz_);
		}
		void* get_parsed_addr() const {
			return m_parsed_addr_;
		}
	
};

enum FIX_VERSION  : std::uint8_t{
	FIX_V4_2 , FIX_V4_4
};
struct alignas(64) parsed_data{
	std::uint64_t m_price ;
	unsigned char m_sendercomp_id[4] ;
	unsigned char m_targetcomp_id[4] ;
	std::uint32_t m_msg_sequence ;
	std::uint32_t m_order_qty ;
	std::uint16_t m_symbol ;
	std::uint8_t m_side;
	std::uint8_t m_order_type;
	std::uint8_t m_fix_version;
	std::uint8_t m_msg_type ;
};

constexpr size_t PARSED_DATA_SZ = sizeof(parsed_data);
constexpr size_t AVG_FIXD_PAYLD_SZ = 128ULL;


// Helper functions 
__attribute__((noinline , cold)) void fail_now(){
	std::fprintf(stderr , "Problem during alllocationa nd initilization\n"); 
	exit(1);
}

// ==============================================================



FIX_Payload_Parser::FIX_Payload_Parser(void* payload_addr , size_t sz ) noexcept{
	if(payload_addr == nullptr || (sz == 0) ){
		fail_now();
	}
	m_payload_addr_ = payload_addr ;
	auto possible_struct_count = (sz / AVG_FIXD_PAYLD_SZ) + (50 * AVG_FIXD_PAYLD_SZ) + 64ULL ;

	auto ptr = mmap(nullptr , possible_struct_count , PROT_READ | PROT_WRITE , MAP_SHARED |MAP_HUGETLB | MAP_HUGE_2MB | MAP_ANONYMOUS , -1 , 0 );
	if(ptr == MAP_FAILED) {
		fail_now();
	}
	int ret = mlock(ptr , possible_struct_count); 
	if(ret == -1 ) {
		fail_now(); 
	}
	ret = madvise(ptr , possible_struct_count , MADV_WILLNEED | MADV_SEQUENTIAL) ; 
	if (ret == - 1){
		fail_now();
	}
	m_parsed_sz_ = possible_struct_count ; 
	m_payload_addr_ = reinterpret_cast<std::uint8_t*>(ptr) + 64ULL ;
	volatile int a ;
	// This is to zero out the cache ready for hot loop 
	for(size_t i{0} ; i < possible_struct_count ; i += (2ULL * 1024ULL * 1024ULL)){
		a = *reinterpret_cast<volatile int*>((reinterpret_cast<std::uint8_t*>(m_payload_addr_) + i));		
	}
	
}

FIX_Payload_Parser::~FIX_Payload_Parser(){
	munmap(m_payload_addr_ , m_parsed_sz_); 
}


int main(){

	return 0;
}
