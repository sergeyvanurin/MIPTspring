// ConsoleApplication2.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <chrono>
#include <stdlib.h>
#include <time.h>

unsigned int one_hash(const std::string& data);

unsigned int length_hash(const std::string& data);

unsigned int sum_hash(const std::string& data);

unsigned int avg_sum_hash(const std::string& data);

unsigned int xor_hash(const std::string& data);

extern "C"
{
	unsigned int asm_xor_hash(const char* data);
}

unsigned int string_asm_xor_hash(const std::string& data);

template<typename T>

class list
{

	private:

	struct node
	{
		bool extra;
		node* next_node;
		T data;
	};

	node* node_init_array;
	node* head;
	node* tail;
	int counter;
	const int INIT_SIZE = 32;

	public:

	list()
	{
		counter = 0;
		node_init_array = new node[INIT_SIZE];
		head = node_init_array;
		for (int i = 0; i < INIT_SIZE - 1; i++)
		{
			head[i].next_node = &head[i + 1];
			head[i].extra = false;
		}
		head[INIT_SIZE - 1].next_node = nullptr;
		head[INIT_SIZE - 1].extra = false;
		tail = head;
	}

	void push_back(const T& inserted_data)
	{
		tail->data = inserted_data;

		if (tail->next_node == nullptr)
		{
			tail->next_node = new node{true, nullptr};
		}

		counter++;
		tail = tail->next_node;
	}

	bool contains(const T& searched_data)
	{
		node* current_node = head;
		while (current_node != tail)
		{
			if (current_node->data == searched_data)
			{
				return true;
			}
			current_node = current_node->next_node;
		}
		return false;
	}

	void remove(const T& removed_data)
	{
		node* current_node = head;
		node* prev_node = nullptr;

		while (current_node != tail)
		{
			if (current_node->data == removed_data)
			{

				if (prev_node != nullptr)
				{
					prev_node->next_node = current_node->next_node;
				}
				else
				{
					head = current_node->next_node;
				}

				current_node->next_node = tail->next_node;
				tail->next_node = current_node;
				break;

			}
			prev_node = current_node;
			current_node = current_node->next_node;
		}
	}

	int size()
	{
		return counter;
	}

	~list()
	{
		node* current_node = head;
		node* next_node = nullptr;
		while (current_node->next_node != nullptr)
		{
			next_node = current_node->next_node;
			if (current_node->extra)
			{
				delete current_node;
			}
			current_node = next_node;
		}
		delete[] node_init_array;
	}
};

template <typename T>
class hashtable
{

	private:

		unsigned int(*hash_function)(const T& element);
		std::vector< list<T> > table;
		unsigned int table_size;

	public:

		hashtable(unsigned int(*hash_func)(const T&), unsigned int size)
		{
			table_size = size;
			hash_function = hash_func;
			table.resize(table_size);
		}

		void insert(const T& new_element)
		{
			//if (contains(new_element)) return;
			unsigned int hash_value = hash_function(new_element) % table_size;
			table[hash_value].push_back(new_element);
		}

		const bool contains(const T& searched_element)
		{
			unsigned int hash_value = hash_function(searched_element) % table_size;
			return table[hash_value].contains(searched_element);
		}

		void remove(const T& removed_element)
		{
			unsigned int hash_value = hash_function(removed_element) % table_size;
			table[hash_value].remove(removed_element);
		}

		const void distribution(std::ofstream& output_file)
		{
			if (!output_file) return;
			for (int i = 0; i < table_size; i++)
			{
				output_file << i << ',' << table[i].size() << '\n';
			}
		}
};

int main()
{
	hashtable<std::string> xor_table(xor_hash, 3677);

	std::ifstream input_file;
	input_file.open("words.txt");

	if (!input_file) return 1;
	const int WORD_COUNT = 300000;
	std::vector<std::string> words_array(WORD_COUNT);

	for (int i = 0; i < WORD_COUNT; i++)
	{
		input_file >> words_array[i];
	}

	input_file.close();

	srand(time(NULL));
	const int EPOCH_SIZE = 25000;
	std::vector<int> inserted(EPOCH_SIZE);

	auto start = std::chrono::high_resolution_clock::now();

	for (int round = 0; round < 7; round++)
	{
		std::cout << round << '\n';
		for (int epoch = 0; epoch < 100; epoch++)
		{

			for (int i = 0; i < EPOCH_SIZE; i++)
			{
				int rand_index = rand() % 40000 + round * 40000;
				xor_table.insert(words_array[rand_index]);
				inserted[i] = rand_index;
			}
			for (int i = 0; i < EPOCH_SIZE; i++)
			{
				xor_table.contains(words_array[rand() % 40000 + round * 40000]);
			}
			for (int i = 0; i < EPOCH_SIZE; i++)
			{
				xor_table.remove(words_array[inserted[i]]);
			}
		}
	}
	auto stop = std::chrono::high_resolution_clock::now();

	auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(stop - start);

	std::cout << "GOODBYE" << ' ' << duration.count() << '\n';
}

unsigned int one_hash(const std::string& data)
{
	return 1;
}

unsigned int length_hash(const std::string& data)
{
	return data.length();
}

unsigned int sum_hash(const std::string& data)
{
	unsigned int sum = 0;
	unsigned int data_length = data.length();

	for (unsigned int i = 0; i < data_length; i++)
	{
		sum += data[i];
	}

	return sum;
}

unsigned int avg_sum_hash(const std::string& data)
{
	unsigned int length = data.length();
	unsigned int sum = sum_hash(data);

	return length ? sum / length : 0;
}

unsigned int xor_hash(const std::string& data)
{
	unsigned int sum = 0;
	unsigned int data_length = data.length();

	for (int i = 0; i < data_length; i++)
	{
		sum ^= data[i];
		sum = (sum << 1) | (sum >> 31);
	}

	return sum;
}

unsigned int string_asm_xor_hash(const std::string& data)
{
	return asm_xor_hash(data.c_str());
}



