package dao;

import malgnsoft.db.*;

public class BoardDao extends DataObject {
    public BoardDao() {
        this.table = "tb_board";
        this.PK = "id";
    }

    public boolean increaseHit(int id) {
        this.item("hit", "", "hit + 1");
        return this.update("id = ?", new Object[]{id});
    }

    public DataSet findByUserId(int userId) {
        return this.find("user_id = ?", new Object[]{userId});
    }

    // 작성자 정보를 포함한 게시글 조회
    public DataSet getWithUser(int id) {
        return this.query(
            "SELECT b.*, u.name as user_name " +
            "FROM tb_board b " +
            "LEFT JOIN tb_user u ON b.user_id = u.id " +
            "WHERE b.id = ?",
            new Object[]{id}
        );
    }
}
