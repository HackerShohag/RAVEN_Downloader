#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged)

public:
    explicit DownloadManager(QObject *parent = nullptr);
    QString author() const;
    void setAuthor(const QString &a);

public slots:
    bool isValidUrl(QString url);
    void sayHello(QString hello);

signals:
    void authorChanged(const QString &m_string);

private:
    QString m_author;
};

#endif // DOWNLOADMANAGER_H
