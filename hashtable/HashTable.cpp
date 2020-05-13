// ConsoleApplication2.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <vector>
#include <string>
#include <fstream>

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
			tail->next_node = new node{ true, nullptr };
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
		unsigned int hash_value = hash_function(new_element) % table_size;
		table[hash_value].push_back(new_element);
	}

	bool contains(const T& searched_element)
	{
		unsigned int hash_value = hash_function(searched_element) % table_size;
		return table[hash_value].contains(searched_element);
	}

	void remove(const T& removed_element)
	{
		unsigned int hash_value = hash_function(removed_element) % table_size;
		table[hash_value].remove(removed_element);
	}

	void distribution(std::ofstream& output_file)
	{
		for (int i = 0; i < table_size; i++)
		{
			output_file << i << ',' << table[i].size() << '\n';
		}
	}
};

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

	for (int i = 0; i < data_length; i++)
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

	for (int i = 0; i < data.length(); i++)
	{
		sum ^= data[i];
		sum = (sum << 1) | (sum >> 31);
	}

	return sum;
}


/*
extern "C" unsigned int asm_xor_hash(const char* data);

unsigned int string_asm_xor_hash(const std::string& data)
{
	return asm_xor_hash(data.c_str());
}
*/

int main()
{
	/*
	hashtable<std::string> one_table(one_hash, 1999);
	hashtable<std::string> length_table(length_hash, 1999);
	hashtable<std::string> sum_table(sum_hash, 1999);
	hashtable<std::string> avg_sum_table(avg_sum_hash, 1999);
	*/
	hashtable<std::string> xor_table(xor_hash, 1999);

	std::ifstream input_file;
	/*
	std::ofstream one_dist;
	std::ofstream length_dist;
	std::ofstream sum_dist;
	std::ofstream avg_sum_dist;
	*/
	std::ofstream xor_dist;

	input_file.open("words.txt");

	std::vector<std::string> words_array(400000);

	for (int i = 0; i < 400000; i++)
	{
		input_file >> words_array[i];
	}

	input_file.close();
	/*
	one_dist.open("one_dist.csv");
	length_dist.open("length_dist.csv");
	sum_dist.open("sum_dist.csv");
	avg_sum_dist.open("avg_dist.csv");
	*/
	xor_dist.open("xor_dist.csv");


	for (int round = 0; round < 4; round++)
	{
		std::cout << round << '\n';
		for (int epoch = 0; epoch < 100; epoch++)
		{
			for (int i = 0; i < 40000; i++)
			{
				xor_table.insert(words_array[i + round * 40000]);
			}
			for (int i = 0; i < 40000; i++)
			{
				if (!xor_table.contains(words_array[i + round * 40000])) return 1;
			}
			for (int i = 0; i < 40000; i++)
			{
				xor_table.remove(words_array[i + round * 40000]);
			}
		}
	}

	/*
	one_table.distribution(one_dist);
	length_table.distribution(length_dist);
	sum_table.distribution(sum_dist);
	avg_sum_table.distribution(avg_sum_dist);
	xor_table.distribution(xor_dist);
	*/

	/*
	one_dist.close();
	length_dist.close();
	sum_dist.close();
	avg_sum_dist.close();
	xor_dist.close();
	*/
	std::cout << "GOODBYE" << '\n';
}
