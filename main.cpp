#include <iostream>
#include <pqxx/pqxx>
#include <string>
#include <vector>
#include <iomanip>

using namespace std;

class FoodOrderDB {
private:
    string connection_string;

public:
    FoodOrderDB(const string& conn_str) : connection_string(conn_str) {}

    void execute_command(const string& sql, const string& desc) {
        try {
            pqxx::connection C(connection_string);
            pqxx::work W(C);
            W.exec(sql);
            W.commit();
            cout << "[SUCCESS] " << desc << endl;
        } catch (const exception &e) {
            cerr << "[ERROR] " << desc << ": " << e.what() << endl;
        }
    }

    void print_query_results(const string& sql, const string& title) {
        try {
            pqxx::connection C(connection_string);
            pqxx::nontransaction N(C);
            pqxx::result R(N.exec(sql));

            cout << "\n--- " << title << " ---" << endl;
            if (R.empty()) {
                cout << "No data found." << endl;
                return;
            }

            for (int col = 0; col < R.columns(); ++col) {
                cout << setw(20) << left << R.column_name(col);
            }
            
            for (const auto& row : R) {
                for (const auto& field : row) {
                    cout << setw(20) << left << field.c_str();
                }
                cout << endl;
            }
        } catch (const exception &e) {
            cerr << "Query execution error: " << e.what() << endl;
        }
    }
};

int main() {
    string conn_str = "dbname=food_order_db user=postgres password=postgres host=localhost port=5432";
    FoodOrderDB db(conn_str);

    //INSERT
    db.execute_command(
        "INSERT INTO customers (name, email, phone, address) VALUES ('Alex Johnson', 'alex@example.com', '555-0101', '123 Main St');",
        "Inserting customer Alex Johnson"
    );

    //UPDATE
    db.execute_command(
        "UPDATE restaurants SET rating = 4.8 WHERE name = 'Bella Italia';",
        "Updating restaurant rating"
    );

    //SELECT с WHERE
    db.print_query_results(
        "SELECT name, price, category FROM menu_items WHERE price < 15.00;",
        "Menu items under $15"
    );

    //INNER JOIN
    db.print_query_results(
        "SELECT c.name as Customer, o.order_date, o.total_amount "
        "FROM orders o "
        "JOIN customers c ON o.customer_id = c.id;",
        "Orders with Customer Names"
    );

    //LEFT JOIN
    db.print_query_results(
        "SELECT r.name FROM restaurants r "
        "LEFT JOIN orders o ON r.id = o.restaurant_id "
        "WHERE o.id IS NULL;",
        "Restaurants with no orders"
    );

    //Агрегатная функция COUNT + GROUP BY (Статистика)
    db.print_query_results(
        "SELECT r.name, COUNT(o.id) as order_count "
        "FROM restaurants r "
        "JOIN orders o ON r.id = o.restaurant_id "
        "GROUP BY r.name;",
        "Number of orders per restaurant"
    );

    //Сложный JOIN (3+ таблицы) + Сортировка
    db.print_query_results(
        "SELECT o.id as OrderID, c.name as Customer, r.name as Restaurant, o.total_amount "
        "FROM orders o "
        "JOIN customers c ON o.customer_id = c.id "
        "JOIN restaurants r ON o.restaurant_id = r.id "
        "ORDER BY o.total_amount DESC;",
        "Orders with Customer and Restaurant details"
    );

    //HAVING (Фильтрация по агрегированным данным)
    db.print_query_results(
        "SELECT r.name, AVG(o.total_amount) as avg_order_value "
        "FROM restaurants r "
        "JOIN orders o ON r.id = o.restaurant_id "
        "GROUP BY r.name "
        "HAVING AVG(o.total_amount) > 25.00;",
        "Restaurants with average order value > $25"
    );

    //Подзапрос
    db.print_query_results(
        "SELECT name, price FROM menu_items "
        "WHERE restaurant_id IN (SELECT id FROM restaurants WHERE rating >= 4.5);",
        "Menu items from highly rated restaurants"
    );

    //DELETE
    db.execute_command(
        "DELETE FROM customers WHERE name = 'Alex Johnson';",
        "Cleaning up: Deleting customer Alex Johnson"
    );

    return 0;
}
