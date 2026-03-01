package dao;

import malgnsoft.db.*;

public class ApplyDao extends DataObject {
    public ApplyDao() {
        this.table = "tb_apply";
        this.PK = "id";
    }

    public DataSet findByEmail(String email) {
        return this.find("email = ?", new Object[]{email});
    }

    public DataSet findByStatus(String status) {
        return this.find("status = ?", new Object[]{status});
    }
}
